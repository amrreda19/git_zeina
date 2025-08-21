-- إضافة إعلانات تجريبية للصفحة الرئيسية
-- هذا الملف يضيف إعلانات تجريبية لاختبار العرض

-- ===== 1. إضافة إعلانات مميزة للصفحة الرئيسية =====

-- إعلان مميز للصفحة الرئيسية
INSERT INTO advertisements (title, description, image_url, link_url, ad_type, position, priority, is_active) VALUES
('كعكة عيد ميلاد مميزة', 'كعكة عيد ميلاد جميلة ومناسبة لجميع المناسبات', 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=400', '#', 'featured', 'homepage_featured', 1, true),
('ديكورات منزلية أنيقة', 'ديكورات منزلية عصرية تناسب جميع الأذواق', 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=400', '#', 'featured', 'homepage_featured', 2, true),
('هدايا عيد الأم', 'مجموعة مميزة من الهدايا المناسبة لعيد الأم', 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400', '#', 'featured', 'homepage_featured', 3, true);

-- ===== 2. إضافة إعلانات موصى بها =====

-- إعلانات موصى بها للصفحة الرئيسية
INSERT INTO advertisements (title, description, image_url, link_url, ad_type, position, priority, is_active) VALUES
('أثاث منزلي كلاسيكي', 'أثاث منزلي كلاسيكي أنيق وعملي', 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=400', '#', 'recommended', 'homepage_recommended', 1, true),
('إكسسوارات عصرية', 'إكسسوارات عصرية تناسب جميع المناسبات', 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=400', '#', 'recommended', 'homepage_recommended', 2, true),
('أدوات مطبخ حديثة', 'أدوات مطبخ حديثة وعملية', 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400', '#', 'recommended', 'homepage_recommended', 3, true);

-- ===== 3. إضافة إعلانات للشريط الجانبي =====

-- إعلانات بانر للشريط الجانبي
INSERT INTO advertisements (title, description, image_url, link_url, ad_type, position, priority, is_active) VALUES
('عروض خاصة', 'عروض خاصة على جميع المنتجات', 'https://images.unsplash.com/photo-1607082349566-187342175e2f?w=300', '#', 'banner', 'sidebar', 1, true),
('منتجات جديدة', 'اكتشف أحدث المنتجات لدينا', 'https://images.unsplash.com/photo-1441984904996-e0b6ba687e04?w=300', '#', 'banner', 'sidebar', 2, true);

-- ===== 4. رسالة تأكيد =====

SELECT 
    'تم إضافة الإعلانات التجريبية بنجاح' AS result,
    COUNT(*) AS total_advertisements,
    COUNT(CASE WHEN ad_type = 'featured' THEN 1 END) AS featured_count,
    COUNT(CASE WHEN ad_type = 'recommended' THEN 1 END) AS recommended_count,
    COUNT(CASE WHEN ad_type = 'banner' THEN 1 END) AS banner_count
FROM advertisements;
