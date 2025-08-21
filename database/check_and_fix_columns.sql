-- فحص وإصلاح أعمدة جدول advertisements
-- هذا الملف يتحقق من وجود الأعمدة المطلوبة ويضيفها إذا لم تكن موجودة

-- ===== 1. فحص الأعمدة الموجودة =====

SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'advertisements' 
ORDER BY ordinal_position;

-- ===== 2. إضافة الأعمدة المفقودة =====

-- إضافة عمود product_id إذا لم يكن موجوداً
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'advertisements' AND column_name = 'product_id'
    ) THEN
        ALTER TABLE advertisements ADD COLUMN product_id UUID;
        RAISE NOTICE 'تم إضافة عمود product_id';
    ELSE
        RAISE NOTICE 'عمود product_id موجود بالفعل';
    END IF;
END $$;

-- إضافة عمود product_category إذا لم يكن موجوداً
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'advertisements' AND column_name = 'product_category'
    ) THEN
        ALTER TABLE advertisements ADD COLUMN product_category VARCHAR(50);
        RAISE NOTICE 'تم إضافة عمود product_category';
    ELSE
        RAISE NOTICE 'عمود product_category موجود بالفعل';
    END IF;
END $$;

-- إضافة عمود clicks_count إذا لم يكن موجوداً
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'advertisements' AND column_name = 'clicks_count'
    ) THEN
        ALTER TABLE advertisements ADD COLUMN clicks_count INTEGER DEFAULT 0;
        RAISE NOTICE 'تم إضافة عمود clicks_count';
    ELSE
        RAISE NOTICE 'عمود clicks_count موجود بالفعل';
    END IF;
END $$;

-- ===== 3. فحص نهائي =====

SELECT 
    'النتيجة النهائية' AS status,
    COUNT(*) AS total_columns,
    COUNT(CASE WHEN column_name IN ('product_id', 'product_category', 'clicks_count') THEN 1 END) AS required_columns_count
FROM information_schema.columns 
WHERE table_name = 'advertisements';

-- ===== 4. عرض الإعلانات الموجودة =====

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
