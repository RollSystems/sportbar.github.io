-- ============================================================
-- SportBar — Configuración de base de datos en Supabase
-- ============================================================
-- Cómo usar este archivo:
-- 1. Entra a tu proyecto en https://supabase.com
-- 2. Ve al menú "SQL Editor" (barra izquierda)
-- 3. Pega todo este contenido y presiona "Run"
-- Con eso queda lista la tabla que usa la app para guardar
-- todos sus datos (productos, mesas, ventas, inventario, etc.)
-- ============================================================

create table if not exists kv_store (
  key text primary key,
  value text not null,
  updated_at timestamptz default now()
);

-- Activa seguridad a nivel de fila (obligatorio en Supabase)
alter table kv_store enable row level security;

-- Políticas abiertas: cualquiera que tenga la URL y la llave "anon"
-- de tu proyecto puede leer y escribir. Esto replica el mismo nivel
-- de seguridad que ya tenía la app (quien tiene el dispositivo/enlace
-- tiene acceso) — es el punto de partida recomendado para empezar.
--
-- Importante: la llave "anon" queda visible en el código de la app del
-- lado del navegador (es pública por diseño en Supabase), así que
-- cualquiera que la obtenga podría leer/escribir tus datos. Si más
-- adelante quieres restringir el acceso (por ejemplo con inicio de
-- sesión por usuario), se puede ajustar estas políticas después.

drop policy if exists "Allow anon select" on kv_store;
create policy "Allow anon select" on kv_store
  for select using (true);

drop policy if exists "Allow anon insert" on kv_store;
create policy "Allow anon insert" on kv_store
  for insert with check (true);

drop policy if exists "Allow anon update" on kv_store;
create policy "Allow anon update" on kv_store
  for update using (true);

drop policy if exists "Allow anon delete" on kv_store;
create policy "Allow anon delete" on kv_store
  for delete using (true);

-- Listo. La app se conecta a esta tabla automáticamente una vez que
-- ingreses la URL del proyecto y la llave "anon" en
-- Configuración → Base de datos (Supabase) dentro de la app.
