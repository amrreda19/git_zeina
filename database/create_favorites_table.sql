-- إنشاء جدول المفضلات المفقود
-- هذا الجدول مطلوب لخدمة المفضلات للعمل بشكل صحيح

-- ===== 1. إنشاء جدول المفضلات =====

CREATE TABLE IF NOT EXISTS public.favorites (
    id SERIAL PRIMARY KEY,
    user_id UUID NOT NULL,
    product_id INTEGER NOT NULL,
    product_table VARCHAR(50) NOT NULL, -- اسم الجدول الذي يحتوي على المنتج
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ===== 2. إضافة الفهارس لتحسين الأداء =====

-- فهرس على user_id للبحث السريع
CREATE INDEX IF NOT EXISTS idx_favorites_user_id ON public.favorites(user_id);

-- فهرس على product_id للبحث السريع
CREATE INDEX IF NOT EXISTS idx_favorites_product_id ON public.favorites(product_id);

-- فهرس مركب على user_id و product_id لمنع التكرار
CREATE UNIQUE INDEX IF NOT EXISTS idx_favorites_user_product_unique 
ON public.favorites(user_id, product_id, product_table);

-- ===== 3. إضافة تعليقات على الجدول =====

COMMENT ON TABLE public.favorites IS 'جدول المفضلات للمستخدمين';
COMMENT ON COLUMN public.favorites.user_id IS 'معرف المستخدم';
COMMENT ON COLUMN public.favorites.product_id IS 'معرف المنتج';
COMMENT ON COLUMN public.favorites.product_table IS 'اسم الجدول الذي يحتوي على المنتج';
COMMENT ON COLUMN public.favorites.created_at IS 'تاريخ إنشاء المفضلة';
COMMENT ON COLUMN public.favorites.updated_at IS 'تاريخ آخر تحديث';

-- ===== 4. إضافة RLS (Row Level Security) إذا كان مطلوباً =====

-- تفعيل RLS على الجدول
ALTER TABLE public.favorites ENABLE ROW LEVEL SECURITY;

-- إنشاء سياسة للسماح للمستخدمين برؤية مفضلاتهم فقط
CREATE POLICY "Users can view their own favorites" ON public.favorites
    FOR SELECT USING (auth.uid() = user_id);

-- إنشاء سياسة للسماح للمستخدمين بإضافة مفضلاتهم
CREATE POLICY "Users can insert their own favorites" ON public.favorites
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- إنشاء سياسة للسماح للمستخدمين بتحديث مفضلاتهم
CREATE POLICY "Users can update their own favorites" ON public.favorites
    FOR UPDATE USING (auth.uid() = user_id);

-- إنشاء سياسة للسماح للمستخدمين بحذف مفضلاتهم
CREATE POLICY "Users can delete their own favorites" ON public.favorites
    FOR DELETE USING (auth.uid() = user_id);

-- ===== 5. رسالة تأكيد =====

SELECT 
    'تم إنشاء جدول المفضلات بنجاح' AS result,
    'favorites' AS table_name,
    'public' AS schema_name;
