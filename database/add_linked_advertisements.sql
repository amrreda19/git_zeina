-- إضافة إعلانات تجريبية مرتبطة بمنتجات حقيقية
-- هذا الملف يضيف إعلانات مرتبطة بمنتجات موجودة فعلاً

-- ===== 1. البحث عن منتجات موجودة =====

-- البحث عن منتج من كل تصنيف
DO $$
DECLARE
    cake_product_id UUID;
    koshat_product_id UUID;
    mirr_product_id UUID;
    other_product_id UUID;
    invitations_product_id UUID;
BEGIN
    -- البحث عن منتج من كل تصنيف
    SELECT id INTO cake_product_id FROM products_cake LIMIT 1;
    SELECT id INTO koshat_product_id FROM products_koshat LIMIT 1;
    SELECT id INTO mirr_product_id FROM products_mirr LIMIT 1;
    SELECT id INTO other_product_id FROM products_other LIMIT 1;
    SELECT id INTO invitations_product_id FROM products_invitations LIMIT 1;
    
    -- ===== 2. إضافة إعلانات مميزة مرتبطة بمنتجات =====
    
    -- إعلان مميز لكعكة
    IF cake_product_id IS NOT NULL THEN
        INSERT INTO advertisements (title, description, ad_type, position, priority, is_active, product_id, product_category) VALUES
        ('كعكة عيد ميلاد مميزة', 'كعكة عيد ميلاد جميلة ومناسبة لجميع المناسبات', 'featured', 'homepage_featured', 1, true, cake_product_id, 'cake');
        RAISE NOTICE 'تم إضافة إعلان كعكة مع المنتج: %', cake_product_id;
    END IF;
    
    -- إعلان مميز لكوشات
    IF koshat_product_id IS NOT NULL THEN
        INSERT INTO advertisements (title, description, ad_type, position, priority, is_active, product_id, product_category) VALUES
        ('كوشة مميزة', 'كوشة أنيقة ومناسبة لجميع المناسبات', 'featured', 'homepage_featured', 2, true, koshat_product_id, 'koshat');
        RAISE NOTICE 'تم إضافة إعلان كوشات مع المنتج: %', koshat_product_id;
    END IF;
    
    -- إعلان مميز لمر
    IF mirr_product_id IS NOT NULL THEN
        INSERT INTO advertisements (title, description, ad_type, position, priority, is_active, product_id, product_category) VALUES
        ('مر مميز', 'مر عالي الجودة ومناسب لجميع الاستخدامات', 'featured', 'homepage_featured', 3, true, mirr_product_id, 'mirr');
        RAISE NOTICE 'تم إضافة إعلان مر مع المنتج: %', mirr_product_id;
    END IF;
    
    -- ===== 3. إضافة إعلانات موصى بها =====
    
    -- إعلان موصى به لمنتجات أخرى
    IF other_product_id IS NOT NULL THEN
        INSERT INTO advertisements (title, description, ad_type, position, priority, is_active, product_id, product_category) VALUES
        ('منتج موصى به', 'منتج عالي الجودة ومناسب لجميع الأذواق', 'recommended', 'homepage_recommended', 1, true, other_product_id, 'other');
        RAISE NOTICE 'تم إضافة إعلان موصى به مع المنتج: %', other_product_id;
    END IF;
    
    -- إعلان موصى به لدعوات وتوزيعات
    IF invitations_product_id IS NOT NULL THEN
        INSERT INTO advertisements (title, description, ad_type, position, priority, is_active, product_id, product_category) VALUES
        ('دعوة مميزة', 'دعوة أنيقة ومناسبة لجميع المناسبات', 'recommended', 'homepage_recommended', 2, true, invitations_product_id, 'invitations');
        RAISE NOTICE 'تم إضافة إعلان دعوات وتوزيعات مع المنتج: %', invitations_product_id;
    END IF;
    
END $$;

-- ===== 4. رسالة تأكيد =====

SELECT 
    'تم إضافة الإعلانات المرتبطة بنجاح' AS result,
    COUNT(*) AS total_advertisements,
    COUNT(CASE WHEN product_id IS NOT NULL THEN 1 END) AS linked_ads,
    COUNT(CASE WHEN product_id IS NULL THEN 1 END) AS unlinked_ads,
    COUNT(CASE WHEN ad_type = 'featured' THEN 1 END) AS featured_count,
    COUNT(CASE WHEN ad_type = 'recommended' THEN 1 END) AS recommended_count
FROM advertisements;
