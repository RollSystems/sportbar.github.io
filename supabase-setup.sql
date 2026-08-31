-- ============================================================
-- SportBar — Esquema de base de datos v2
-- Tablas reales (una fila por registro) + multi-negocio
-- ============================================================
-- Qué cambia respecto al esquema anterior (kv_store con un solo
-- bloque JSON gigante por colección):
--   - Ventas, movimientos (kardex), ingresos, salidas y cuentas
--     por cobrar ahora son tablas reales: cada registro es su
--     propia fila. Cada venta nueva solo sube esa fila, no el
--     historial completo — esto evita quedarse sin tráfico (egress)
--     del plan gratuito a medida que crece el historial.
--   - Cada negocio se identifica por el usuario que inició sesión
--     (auth.uid()). Varios negocios pueden compartir el mismo
--     proyecto de Supabase sin ver los datos de los demás — cada
--     uno necesita su propio usuario (Authentication → Users).
--   - Productos, mesas/barra, ofertas y configuración siguen
--     guardándose como bloques (kv_store) porque son pocos datos
--     y no crecen sin límite — pero ahora separados por negocio.
--
-- Cómo usar este archivo:
-- 1. Entra a tu proyecto en https://supabase.com → SQL Editor
-- 2. Pega todo este contenido y presiona "Run"
-- 3. Si vienes del esquema anterior: antes de correr esto, entra a
--    la app y usa Configuración → "Respaldar ahora" para guardar
--    tus datos actuales. Después de correr este SQL, usa
--    "Restaurar desde archivo" con ese respaldo para recuperarlos
--    dentro del nuevo esquema.
-- ============================================================

-- ---------- kv_store (productos, mesas/barra, ofertas, configuración) ----------
-- Si ya existe de la versión anterior (sin business_id), se actualiza en su lugar.
create table if not exists kv_store (
  business_id uuid not null default auth.uid(),
  key text not null,
  value text not null,
  updated_at timestamptz default now(),
  primary key (business_id, key)
);

-- Migración suave: si la tabla ya existía con "key" como llave única (esquema viejo),
-- esto la deja con la nueva llave compuesta sin perder los datos existentes.
do $$
begin
  if exists (
    select 1 from information_schema.table_constraints
    where table_name = 'kv_store' and constraint_type = 'PRIMARY KEY' and constraint_name = 'kv_store_pkey'
  ) then
    begin
      alter table kv_store drop constraint kv_store_pkey;
      alter table kv_store add primary key (business_id, key);
    exception when others then
      null; -- ya estaba en el formato nuevo
    end;
  end if;
end $$;

alter table kv_store enable row level security;

drop policy if exists "Allow anon select" on kv_store;
drop policy if exists "Require auth select" on kv_store;
drop policy if exists "kv_store select own" on kv_store;
create policy "kv_store select own" on kv_store
  for select using (business_id = auth.uid());

drop policy if exists "Allow anon insert" on kv_store;
drop policy if exists "Require auth insert" on kv_store;
drop policy if exists "kv_store insert own" on kv_store;
create policy "kv_store insert own" on kv_store
  for insert with check (business_id = auth.uid());

drop policy if exists "Allow anon update" on kv_store;
drop policy if exists "Require auth update" on kv_store;
drop policy if exists "kv_store update own" on kv_store;
create policy "kv_store update own" on kv_store
  for update using (business_id = auth.uid());

drop policy if exists "Allow anon delete" on kv_store;
drop policy if exists "Require auth delete" on kv_store;
drop policy if exists "kv_store delete own" on kv_store;
create policy "kv_store delete own" on kv_store
  for delete using (business_id = auth.uid());


-- ---------- sales (ventas) ----------
create table if not exists sales (
  id text primary key,
  business_id uuid not null default auth.uid(),
  date text,
  time text,
  table_id text,
  table_name text,
  items jsonb,
  total numeric,
  payment_method text,
  created_at timestamptz default now()
);
alter table sales enable row level security;
drop policy if exists "sales select own" on sales;
create policy "sales select own" on sales for select using (business_id = auth.uid());
drop policy if exists "sales insert own" on sales;
create policy "sales insert own" on sales for insert with check (business_id = auth.uid());
drop policy if exists "sales update own" on sales;
create policy "sales update own" on sales for update using (business_id = auth.uid());

-- ---------- movements (kardex) ----------
create table if not exists movements (
  id text primary key,
  business_id uuid not null default auth.uid(),
  ts bigint,
  date text,
  product_id text,
  type text,
  qty numeric,
  ref text,
  created_at timestamptz default now()
);
alter table movements enable row level security;
drop policy if exists "movements select own" on movements;
create policy "movements select own" on movements for select using (business_id = auth.uid());
drop policy if exists "movements insert own" on movements;
create policy "movements insert own" on movements for insert with check (business_id = auth.uid());
drop policy if exists "movements update own" on movements;
create policy "movements update own" on movements for update using (business_id = auth.uid());

-- ---------- incomes (ingresos de mercadería) ----------
create table if not exists incomes (
  id text primary key,
  business_id uuid not null default auth.uid(),
  correlativo int,
  invoice text,
  date text,
  items jsonb,
  created_at timestamptz default now()
);
alter table incomes enable row level security;
drop policy if exists "incomes select own" on incomes;
create policy "incomes select own" on incomes for select using (business_id = auth.uid());
drop policy if exists "incomes insert own" on incomes;
create policy "incomes insert own" on incomes for insert with check (business_id = auth.uid());
drop policy if exists "incomes update own" on incomes;
create policy "incomes update own" on incomes for update using (business_id = auth.uid());

-- ---------- outages (salidas por deterioro/vencimiento) ----------
create table if not exists outages (
  id text primary key,
  business_id uuid not null default auth.uid(),
  correlativo int,
  reason text,
  date text,
  items jsonb,
  created_at timestamptz default now()
);
alter table outages enable row level security;
drop policy if exists "outages select own" on outages;
create policy "outages select own" on outages for select using (business_id = auth.uid());
drop policy if exists "outages insert own" on outages;
create policy "outages insert own" on outages for insert with check (business_id = auth.uid());
drop policy if exists "outages update own" on outages;
create policy "outages update own" on outages for update using (business_id = auth.uid());

-- ---------- pending_accounts (cuentas por cobrar) ----------
create table if not exists pending_accounts (
  id text primary key,
  business_id uuid not null default auth.uid(),
  date text,
  ts bigint,
  table_name text,
  client_name text,
  total numeric,
  items jsonb,
  status text,
  payment_method text,
  created_at timestamptz default now()
);
alter table pending_accounts enable row level security;
drop policy if exists "pending_accounts select own" on pending_accounts;
create policy "pending_accounts select own" on pending_accounts for select using (business_id = auth.uid());
drop policy if exists "pending_accounts insert own" on pending_accounts;
create policy "pending_accounts insert own" on pending_accounts for insert with check (business_id = auth.uid());
drop policy if exists "pending_accounts update own" on pending_accounts;
create policy "pending_accounts update own" on pending_accounts for update using (business_id = auth.uid());

-- ============================================================
-- Listo. Para agregar otro negocio al mismo proyecto:
-- Authentication → Users → "Add user" (otro correo/contraseña).
-- Cada quien solo verá los datos creados con su propia sesión.
-- ============================================================
