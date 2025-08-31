-- 🔍 مقارنة صلاحيات الجداول - بوكيهات الورد vs الجداول الأخرى
-- تنفيذ هذه الأوامر في Supabase SQL Editor

-- 1. مقارنة وجود الجداول
SELECT 
    'products_cake' as table_name,
    EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'products_cake') as exists
UNION ALL
SELECT 
    'products_koshat' as table_name,
    EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'products_koshat') as exists
UNION ALL
SELECT 
    'products_mirr' as table_name,
    EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'products_mirr') as exists
UNION ALL
SELECT 
    'products_other' as table_name,
    EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'products_other') as exists
UNION ALL
SELECT 
    'products_invitations' as table_name,
    EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'products_invitations') as exists
UNION ALL
SELECT 
    'products_flowerbouquets' as table_name,
    EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'products_flowerbouquets') as exists;

-- 2. مقارنة هيكل الجداول
-- جدول بوكيهات الورد
SELECT 
    'products_flowerbouquets' as table_name,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'products_flowerbouquets'
ORDER BY ordinal_position;

-- جدول التورت (لل مقارنة)
SELECT 
    'products_cake' as table_name,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'products_cake'
ORDER BY ordinal_position;

-- 3. مقارنة الصلاحيات
-- صلاحيات بوكيهات الورد
SELECT 
    'products_flowerbouquets' as table_name,
    grantee,
    privilege_type,
    is_grantable
FROM information_schema.role_table_grants 
WHERE table_name = 'products_flowerbouquets'
ORDER BY grantee, privilege_type;

-- صلاحيات التورت (لل مقارنة)
SELECT 
    'products_cake' as table_name,
    grantee,
    privilege_type,
    is_grantable
FROM information_schema.role_table_grants 
WHERE table_name = 'products_cake'
ORDER BY grantee, privilege_type;

-- 4. مقارنة RLS
-- RLS بوكيهات الورد
SELECT 
    'products_flowerbouquets' as table_name,
    schemaname,
    tablename,
    rowsecurity
FROM pg_tables 
WHERE tablename = 'products_flowerbouquets';

-- RLS التورت (لل مقارنة)
SELECT 
    'products_cake' as table_name,
    schemaname,
    tablename,
    rowsecurity
FROM pg_tables 
WHERE tablename = 'products_cake';

-- 5. مقارنة السياسات
-- سياسات بوكيهات الورد
SELECT 
    'products_flowerbouquets' as table_name,
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual
FROM pg_policies 
WHERE tablename = 'products_flowerbouquets'
ORDER BY policyname;

-- سياسات التورت (لل مقارنة)
SELECT 
    'products_cake' as table_name,
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual
FROM pg_policies 
WHERE tablename = 'products_cake'
ORDER BY policyname;

-- 6. فحص البيانات
-- عدد المنتجات في كل جدول
SELECT 
    'products_cake' as table_name,
    COUNT(*) as product_count
FROM products_cake
UNION ALL
SELECT 
    'products_koshat' as table_name,
    COUNT(*) as product_count
FROM products_koshat
UNION ALL
SELECT 
    'products_mirr' as table_name,
    COUNT(*) as product_count
FROM products_mirr
UNION ALL
SELECT 
    'products_other' as table_name,
    COUNT(*) as product_count
FROM products_other
UNION ALL
SELECT 
    'products_invitations' as table_name,
    COUNT(*) as product_count
FROM products_invitations
UNION ALL
SELECT 
    'products_flowerbouquets' as table_name,
    COUNT(*) as product_count
FROM products_flowerbouquets;

-- 7. فحص المستخدم الحالي
SELECT 
    current_user,
    session_user,
    current_database(),
    current_schema();

-- 8. فحص الأدوار
SELECT 
    rolname,
    rolsuper,
    rolinherit,
    rolcreaterole,
    rolcreatedb,
    rolcanlogin
FROM pg_roles 
WHERE rolname IN ('authenticated', 'anon', 'service_role', current_user);
