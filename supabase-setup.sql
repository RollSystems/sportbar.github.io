-- ============================================================
-- SportBar — Configuración de base de datos en Supabase
-- (con inicio de sesión requerido)
-- ============================================================
-- Cómo usar este archivo:
-- 1. Entra a tu proyecto en https://supabase.com
-- 2. Ve al menú "SQL Editor" (barra izquierda)
-- 3. Pega todo este contenido y presiona "Run"
-- 4. Ve a Authentication → Users → "Add user" y crea el usuario
--    (correo + contraseña) con el que se iniciará sesión en la app.
-- ============================================================

create table if not exists kv_store (
  key text primary key,
  value text not null,
  updated_at timestamptz default now()
);

-- Activa seguridad a nivel de fila (obligatorio en Supabase)
alter table kv_store enable row level security;

-- Políticas restringidas: solo se puede leer o escribir si hay una
-- sesión iniciada (auth.uid() no es nulo). La llave "anon" por sí sola
-- ya NO alcanza para acceder a los datos — hace falta iniciar sesión
-- con un usuario válido (creado en Authentication → Users).

drop policy if exists "Allow anon select" on kv_store;
drop policy if exists "Require auth select" on kv_store;
create policy "Require auth select" on kv_store
  for select using (auth.uid() is not null);

drop policy if exists "Allow anon insert" on kv_store;
drop policy if exists "Require auth insert" on kv_store;
create policy "Require auth insert" on kv_store
  for insert with check (auth.uid() is not null);

drop policy if exists "Allow anon update" on kv_store;
drop policy if exists "Require auth update" on kv_store;
create policy "Require auth update" on kv_store
  for update using (auth.uid() is not null);

drop policy if exists "Allow anon delete" on kv_store;
drop policy if exists "Require auth delete" on kv_store;
create policy "Require auth delete" on kv_store
  for delete using (auth.uid() is not null);

-- Listo. La app pedirá correo y contraseña antes de mostrar cualquier
-- dato — solo quien tenga esas credenciales podrá leer o escribir.
