-- إضافة الأعمدة المفقودة لجدول advertisements
-- هذا الملف يضيف الأعمدة المطلوبة لربط الإعلانات بالمنتجات

-- ===== 1. إضافة عمود product_id =====
ALTER TABLE advertisements ADD COLUMN IF NOT EXISTS product_id UUID;

-- ===== 2. إضافة عمود product_category =====
ALTER TABLE advertisements ADD COLUMN IF NOT EXISTS product_category VARCHAR(50);

-- ===== 3. إضافة عمود clicks_count =====
ALTER TABLE advertisements ADD COLUMN IF NOT EXISTS clicks_count INTEGER DEFAULT 0;

-- ===== 4. فحص النتيجة =====
SELECT 
    'تم إضافة الأعمدة المفقودة' AS result,
    COUNT(*) AS total_columns,
    COUNT(CASE WHEN column_name IN ('product_id', 'product_category', 'clicks_count') THEN 1 END) AS required_columns_count
FROM information_schema.columns 
WHERE table_name = 'advertisements';

-- ===== 5. عرض الإعلانات الموجودة =====
SELECT 
    id,
    title,
    ad_type,
    position,
    product_id,
    product_category,
    is_active,
    created_at
FROM advertisements 
ORDER BY created_at DESC;
