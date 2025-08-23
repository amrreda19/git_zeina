/**
 * خدمة إدارة طلبات المنتجات
 * 
 * المنطق الجديد:
 * ✅ عند الموافقة: نقل البيانات للجدول الرئيسي + حذف الطلب نهائياً
 * ❌ عند الرفض: حذف الطلب والصورة نهائياً من النظام
 * 
 * جدول Project Request يصبح محطة مؤقتة فقط
 */
class ProductRequestsService {
    constructor() {
        this.supabase = null;
        this.initialized = false;
        this.initPromise = this.initialize();
    }

    async initialize() {
        try {
            console.log('🔄 ProductRequestsService: Starting initialization...');
            
            // Wait for Supabase client to be available
            if (window.supabaseClient) {
                this.supabase = window.supabaseClient;
                this.initialized = true;
                console.log('✅ ProductRequestsService: Supabase client already available');
            } else {
                console.log('⏳ ProductRequestsService: Waiting for Supabase client...');
                
                // Wait for initialization
                await new Promise((resolve) => {
                    let attempts = 0;
                    const maxAttempts = 150; // 15 seconds
                    
                    const checkInterval = setInterval(() => {
                        attempts++;
                        
                        if (window.supabaseClient) {
                            clearInterval(checkInterval);
                            this.supabase = window.supabaseClient;
                            this.initialized = true;
                            console.log('✅ ProductRequestsService: Supabase client loaded successfully');
                            resolve();
                        } else if (attempts >= maxAttempts) {
                            clearInterval(checkInterval);
                            console.error('❌ ProductRequestsService: Supabase client not loaded after 15 seconds');
                            resolve();
                        } else if (attempts % 10 === 0) {
                            console.log(`⏳ ProductRequestsService: Waiting for Supabase client... (attempt ${attempts}/${maxAttempts})`);
                        }
                    }, 100);
                });
            }
            
            if (this.supabase) {
                this.initialized = true;
                console.log('✅ ProductRequestsService initialized successfully with Supabase client');
            } else {
                console.error('❌ ProductRequestsService: Failed to initialize Supabase client');
            }
        } catch (error) {
            console.error('❌ ProductRequestsService initialization error:', error);
        }
    }

    // Helper method to ensure initialization
    async ensureInitialized() {
        if (!this.initialized) {
            console.log('🔄 ProductRequestsService: Ensuring initialization...');
            await this.initialize();
        }
        return this.supabase !== null && this.initialized;
    }

    // Submit a new product request from visitors
    async submitProductRequest(requestData, imageFiles) {
        try {
            const isReady = await this.ensureInitialized();
            if (!isReady) {
                return { success: false, error: 'ProductRequestsService not initialized' };
            }

            console.log('📝 Submitting product request:', requestData);

            // Upload images to temporary storage
            const imageUrls = await this.uploadRequestImages(imageFiles);
            
            // Prepare request data
            const requestToInsert = {
                ...requestData,
                image_urls: imageUrls,
                status: 'pending', // pending, approved, rejected
                created_at: new Date().toISOString(),
                updated_at: new Date().toISOString()
            };

            // Insert request into product_requests table
            const { data, error } = await this.supabase
                .from('product_requests')
                .insert([requestToInsert])
                .select();

            if (error) {
                console.error('Error submitting product request:', error);
                return { success: false, error: error.message };
            }

            console.log('✅ Product request submitted successfully');
            return { success: true, data: data[0] };
        } catch (error) {
            console.error('Error in submitProductRequest:', error);
            return { success: false, error: error.message };
        }
    }

    // Upload images for product requests (temporary storage)
    async uploadRequestImages(imageFiles) {
        try {
            if (!imageFiles || imageFiles.length === 0) {
                return [];
            }

            const imageUrls = [];
            const timestamp = Date.now();

            for (let i = 0; i < imageFiles.length; i++) {
                const file = imageFiles[i];
                const fileName = `product_request_${timestamp}_${i}_${file.name}`;
                const filePath = `Product_requests/${fileName}`;

                console.log(`📤 Uploading image ${i + 1}/${imageFiles.length}: ${fileName}`);

                const { data, error } = await this.supabase.storage
                    .from('images')
                    .upload(filePath, file, {
                        cacheControl: '3600',
                        upsert: false
                    });

                if (error) {
                    console.error(`Error uploading image ${fileName}:`, error);
                    continue;
                }

                // Get public URL
                const { data: urlData } = this.supabase.storage
                    .from('images')
                    .getPublicUrl(filePath);

                if (urlData?.publicUrl) {
                    imageUrls.push({
                        url: urlData.publicUrl,
                        path: filePath,
                        original_name: file.name
                    });
                    console.log(`✅ Image uploaded successfully: ${fileName}`);
                }
            }

            return imageUrls;
        } catch (error) {
            console.error('Error uploading request images:', error);
            return [];
        }
    }

    // Get all product requests (for admin)
    async getAllProductRequests() {
        try {
            const isReady = await this.ensureInitialized();
            if (!isReady) {
                return { success: false, error: 'ProductRequestsService not initialized' };
            }

            const { data, error } = await this.supabase
                .from('product_requests')
                .select('*')
                .order('created_at', { ascending: false });

            if (error) {
                console.error('Error fetching product requests:', error);
                return { success: false, error: error.message };
            }

            return { success: true, data: data || [] };
        } catch (error) {
            console.error('Error in getAllProductRequests:', error);
            return { success: false, error: error.message };
        }
    }

    // Get product requests by status
    async getProductRequestsByStatus(status) {
        try {
            const isReady = await this.ensureInitialized();
            if (!isReady) {
                return { success: false, error: 'ProductRequestsService not initialized' };
            }

            const { data, error } = await this.supabase
                .from('product_requests')
                .select('*')
                .eq('status', status)
                .order('created_at', { ascending: false });

            if (error) {
                console.error(`Error fetching ${status} product requests:`, error);
                return { success: false, error: error.message };
            }

            return { success: true, data: data || [] };
        } catch (error) {
            console.error('Error in getProductRequestsByStatus:', error);
            return { success: false, error: error.message };
        }
    }

    // Approve a product request
    // ✅ الموافقة على الطلب: نقل البيانات للجدول الرئيسي ثم حذف الطلب نهائياً
    async approveProductRequest(requestId) {
        try {
            const isReady = await this.ensureInitialized();
            if (!isReady) {
                return { success: false, error: 'ProductRequestsService not initialized' };
            }

            console.log(`✅ Approving product request: ${requestId}`);

            // Get the request details
            const { data: request, error: fetchError } = await this.supabase
                .from('product_requests')
                .select('*')
                .eq('id', requestId)
                .single();

            if (fetchError || !request) {
                console.error('Error fetching request for approval:', fetchError);
                return { success: false, error: 'Request not found' };
            }

            // Move images to final location
            const finalImageUrls = await this.moveImagesToFinalLocation(request.image_urls, request.category);

            // Create the actual product
            const productData = {
                title: request.description, // استخدام الوصف كعنوان
                description: request.description,
                price: request.price || 0,
                category: request.category,
                subcategory: request.subcategory,
                governorate: request.governorate,
                cities: request.cities,
                whatsapp: request.whatsapp,
                facebook: request.facebook,
                instagram: request.instagram,
                image_urls: finalImageUrls,
                created_at: new Date().toISOString(),
                updated_at: new Date().toISOString()
            };

            // Insert into the appropriate products table
            const tableName = this.getTableName(request.category);
            const { data: product, error: productError } = await this.supabase
                .from(tableName)
                .insert([productData])
                .select();

            if (productError) {
                console.error(`Error creating product in ${tableName}:`, productError);
                return { success: false, error: `Failed to create product: ${productError.message}` };
            }

            // Delete the request completely after successful approval
            console.log(`🗑️ Attempting to delete approved request: ${requestId}`);
            
            let deleteSuccess = false;
            let deleteAttempts = 0;
            const maxAttempts = 3;
            
            while (!deleteSuccess && deleteAttempts < maxAttempts) {
                deleteAttempts++;
                console.log(`🗑️ Delete attempt ${deleteAttempts}/${maxAttempts} for approved request: ${requestId}`);
                
                try {
                    // First, try to update the status to 'approved' before deletion
                    const { error: updateError } = await this.supabase
                        .from('product_requests')
                        .update({ 
                            status: 'approved',
                            updated_at: new Date().toISOString()
                        })
                        .eq('id', requestId);
                    
                    if (updateError) {
                        console.warn(`⚠️ Could not update status to approved:`, updateError);
                    }
                    
                    // Now try to delete the request
                    const { data: deleteData, error: deleteError } = await this.supabase
                        .from('product_requests')
                        .delete()
                        .eq('id', requestId)
                        .select();

                    console.log(`🗑️ Delete operation result (attempt ${deleteAttempts}):`, { data: deleteData, error: deleteError });

                    if (deleteError) {
                        console.error(`❌ Delete attempt ${deleteAttempts} failed:`, deleteError);
                        
                        // Check if it's a permission issue
                        if (deleteError.code === '42501' || deleteError.message.includes('permission')) {
                            console.error('❌ Permission denied for deletion');
                            return { success: false, error: 'Product created but request deletion failed due to permissions' };
                        }
                        
                        // Wait before retry
                        if (deleteAttempts < maxAttempts) {
                            await new Promise(resolve => setTimeout(resolve, 1000));
                        }
                    } else {
                        deleteSuccess = true;
                        console.log(`✅ Delete successful on attempt ${deleteAttempts}`);
                    }
                } catch (attemptError) {
                    console.error(`❌ Delete attempt ${deleteAttempts} threw error:`, attemptError);
                    if (deleteAttempts < maxAttempts) {
                        await new Promise(resolve => setTimeout(resolve, 1000));
                    }
                }
            }

            if (!deleteSuccess) {
                console.error('❌ All delete attempts failed for approved request');
                return { success: false, error: 'Product created but request could not be deleted' };
            }

            // Verify that the request was actually deleted
            console.log(`🔍 Verifying deletion of approved request: ${requestId}`);
            
            // Wait a moment for database consistency
            await new Promise(resolve => setTimeout(resolve, 500));
            
            const { data: verifyRequest, error: verifyError } = await this.supabase
                .from('product_requests')
                .select('id')
                .eq('id', requestId)
                .single();
                
            if (verifyError && verifyError.code === 'PGRST116') {
                console.log('✅ Approved request successfully deleted (not found during verification)');
            } else if (verifyRequest) {
                console.warn('⚠️ Approved request still exists after deletion attempt!');
                console.warn('⚠️ This indicates a deletion failure');
                
                // Try one more time with force delete
                console.log('🔄 Attempting force delete for approved request...');
                try {
                    // Check if the function exists first
                    const { error: functionCheckError } = await this.supabase
                        .rpc('force_delete_product_request', { request_id: requestId });
                    
                    if (functionCheckError) {
                        console.warn('⚠️ Force delete function not available for approved request, trying alternative methods...');
                        
                        // Try direct deletion with elevated permissions
                        console.log('🔄 Attempting direct deletion with elevated permissions for approved request...');
                        try {
                            // Try to delete with a different approach
                            const { data: directDeleteData, error: directDeleteError } = await this.supabase
                                .from('product_requests')
                                .delete()
                                .eq('id', requestId)
                                .select();
                            
                            if (directDeleteError) {
                                console.warn('⚠️ Direct deletion for approved request also failed:', directDeleteError);
                                
                                // Try one more time with a delay
                                console.log('🔄 Waiting and trying one more time for approved request...');
                                await new Promise(resolve => setTimeout(resolve, 2000));
                                
                                const { data: finalDeleteData, error: finalDeleteError } = await this.supabase
                                    .from('product_requests')
                                    .delete()
                                    .eq('id', requestId)
                                    .select();
                                
                                if (finalDeleteError) {
                                    console.error('❌ Final deletion attempt for approved request failed:', finalDeleteError);
                                    return { success: false, error: 'Product created but request could not be deleted completely' };
                                } else {
                                    console.log('✅ Final deletion attempt for approved request successful');
                                }
                            } else {
                                console.log('✅ Direct deletion for approved request successful');
                            }
                        } catch (directError) {
                            console.error('❌ Direct deletion error for approved request:', directError);
                            return { success: false, error: 'Product created but request could not be deleted completely' };
                        }
                    } else {
                        console.log('✅ Force delete for approved request successful');
                    }
                } catch (forceError) {
                    console.error('❌ Force delete error for approved request:', forceError);
                    
                    // Try alternative force delete function
                    console.log('🔄 Attempting alternative force delete for approved request after error...');
                    try {
                        const { error: altForceDeleteError } = await this.supabase
                            .rpc('force_delete_product_request_rls', { request_id: requestId });
                        
                        if (altForceDeleteError) {
                            console.warn('⚠️ Alternative force delete function not available for approved request, trying direct deletion...');
                            
                            // Try direct deletion as fallback
                            const { data: fallbackDeleteData, error: fallbackDeleteError } = await this.supabase
                                .from('product_requests')
                                .delete()
                                .eq('id', requestId)
                                .select();
                            
                            if (fallbackDeleteError) {
                                console.error('❌ Fallback deletion for approved request also failed:', fallbackDeleteError);
                                return { success: false, error: 'Product created but request could not be deleted completely' };
                            } else {
                                console.log('✅ Fallback deletion for approved request successful');
                            }
                        } else {
                            console.log('✅ Alternative force delete for approved request successful');
                        }
                    } catch (altForceError) {
                        console.error('❌ Alternative force delete error for approved request:', altForceError);
                        
                        // Final fallback: try direct deletion
                        console.log('🔄 Attempting final fallback deletion for approved request...');
                        try {
                            const { data: finalFallbackData, error: finalFallbackError } = await this.supabase
                                .from('product_requests')
                                .delete()
                                .eq('id', requestId)
                                .select();
                            
                            if (finalFallbackError) {
                                console.error('❌ Final fallback deletion for approved request failed:', finalFallbackError);
                                return { success: false, error: 'Product created but request could not be deleted completely' };
                            } else {
                                console.log('✅ Final fallback deletion for approved request successful');
                            }
                        } catch (finalFallbackError) {
                            console.error('❌ Final fallback deletion error for approved request:', finalFallbackError);
                            return { success: false, error: 'Product created but request could not be deleted completely' };
                        }
                    }
                }
            } else {
                console.log('✅ Approved request deletion verified successfully');
            }

            console.log('✅ Product request approved, product created, and request deleted successfully');
            return { success: true, data: product[0] };
        } catch (error) {
            console.error('Error in approveProductRequest:', error);
            return { success: false, error: error.message };
        }
    }

    // Reject a product request
    // ❌ رفض الطلب: حذف الطلب والصورة نهائياً من النظام
    async rejectProductRequest(requestId, rejectionReason = '') {
        try {
            const isReady = await this.ensureInitialized();
            if (!isReady) {
                return { success: false, error: 'ProductRequestsService not initialized' };
            }

            console.log(`❌ Rejecting product request: ${requestId}`);

            // Get the request details first to access image paths
            const { data: request, error: fetchError } = await this.supabase
                .from('product_requests')
                .select('*')
                .eq('id', requestId)
                .single();

            if (fetchError || !request) {
                console.error('Error fetching request for rejection:', fetchError);
                return { success: false, error: 'Request not found' };
            }

            // Delete images from storage if they exist
            if (request.image_urls && request.image_urls.length > 0) {
                await this.deleteRequestImages(request.image_urls);
            }

            // Delete the request completely with multiple attempts
            console.log(`🗑️ Attempting to delete rejected request: ${requestId}`);
            
            let deleteSuccess = false;
            let deleteAttempts = 0;
            const maxAttempts = 3;
            
            while (!deleteSuccess && deleteAttempts < maxAttempts) {
                deleteAttempts++;
                console.log(`🗑️ Delete attempt ${deleteAttempts}/${maxAttempts} for request: ${requestId}`);
                
                try {
                    // First, try to update the status to 'rejected' before deletion
                    const { error: updateError } = await this.supabase
                        .from('product_requests')
                        .update({ 
                            status: 'rejected',
                            updated_at: new Date().toISOString(),
                            rejection_reason: rejectionReason || null
                        })
                        .eq('id', requestId);
                    
                    if (updateError) {
                        console.warn(`⚠️ Could not update status to rejected:`, updateError);
                    }
                    
                    // Now try to delete the request
                    const { data: deleteData, error: deleteError } = await this.supabase
                        .from('product_requests')
                        .delete()
                        .eq('id', requestId)
                        .select();

                    console.log(`🗑️ Delete operation result (attempt ${deleteAttempts}):`, { data: deleteData, error: deleteError });

                    if (deleteError) {
                        console.error(`❌ Delete attempt ${deleteAttempts} failed:`, deleteError);
                        
                        // Check if it's a permission issue
                        if (deleteError.code === '42501' || deleteError.message.includes('permission')) {
                            console.error('❌ Permission denied for deletion');
                            return { success: false, error: 'Permission denied: Cannot delete this request' };
                        }
                        
                        // Wait before retry
                        if (deleteAttempts < maxAttempts) {
                            await new Promise(resolve => setTimeout(resolve, 1000));
                        }
                    } else {
                        deleteSuccess = true;
                        console.log(`✅ Delete successful on attempt ${deleteAttempts}`);
                    }
                } catch (attemptError) {
                    console.error(`❌ Delete attempt ${deleteAttempts} threw error:`, attemptError);
                    if (deleteAttempts < maxAttempts) {
                        await new Promise(resolve => setTimeout(resolve, 1000));
                    }
                }
            }

            if (!deleteSuccess) {
                console.error('❌ All delete attempts failed');
                return { success: false, error: 'Failed to delete request after multiple attempts' };
            }

            // Verify that the request was actually deleted
            console.log(`🔍 Verifying deletion of request: ${requestId}`);
            
            // Wait a moment for database consistency
            await new Promise(resolve => setTimeout(resolve, 500));
            
            const { data: verifyRequest, error: verifyError } = await this.supabase
                .from('product_requests')
                .select('id')
                .eq('id', requestId)
                .single();
                
            if (verifyError && verifyError.code === 'PGRST116') {
                console.log('✅ Request successfully deleted (not found during verification)');
            } else if (verifyRequest) {
                console.warn('⚠️ Request still exists after deletion attempt!');
                console.warn('⚠️ This indicates a deletion failure');
                
                // Try one more time with force delete
                console.log('🔄 Attempting force delete...');
                try {
                    // Check if the function exists first
                    const { error: functionCheckError } = await this.supabase
                        .rpc('force_delete_product_request', { request_id: requestId });
                    
                    if (functionCheckError) {
                        console.warn('⚠️ Force delete function not available, trying alternative methods...');
                        
                        // Try direct deletion with elevated permissions
                        console.log('🔄 Attempting direct deletion with elevated permissions...');
                        try {
                            // Try to delete with a different approach
                            const { data: directDeleteData, error: directDeleteError } = await this.supabase
                                .from('product_requests')
                                .delete()
                                .eq('id', requestId)
                                .select();
                            
                            if (directDeleteError) {
                                console.warn('⚠️ Direct deletion also failed:', directDeleteError);
                                
                                // Try one more time with a delay
                                console.log('🔄 Waiting and trying one more time...');
                                await new Promise(resolve => setTimeout(resolve, 2000));
                                
                                const { data: finalDeleteData, error: finalDeleteError } = await this.supabase
                                    .from('product_requests')
                                    .delete()
                                    .eq('id', requestId)
                                    .select();
                                
                                if (finalDeleteError) {
                                    console.error('❌ Final deletion attempt failed:', finalDeleteError);
                                    return { success: false, error: 'Request could not be deleted completely' };
                                } else {
                                    console.log('✅ Final deletion attempt successful');
                                }
                            } else {
                                console.log('✅ Direct deletion successful');
                            }
                        } catch (directError) {
                            console.error('❌ Direct deletion error:', directError);
                            return { success: false, error: 'Request could not be deleted completely' };
                        }
                    } else {
                        console.log('✅ Force delete successful');
                    }
                } catch (forceError) {
                    console.error('❌ Force delete error:', forceError);
                    
                    // Try alternative force delete function
                    console.log('🔄 Attempting alternative force delete after error...');
                    try {
                        const { error: altForceDeleteError } = await this.supabase
                            .rpc('force_delete_product_request_rls', { request_id: requestId });
                        
                        if (altForceDeleteError) {
                            console.warn('⚠️ Alternative force delete function not available, trying direct deletion...');
                            
                            // Try direct deletion as fallback
                            const { data: fallbackDeleteData, error: fallbackDeleteError } = await this.supabase
                                .from('product_requests')
                                .delete()
                                .eq('id', requestId)
                                .select();
                            
                            if (fallbackDeleteError) {
                                console.error('❌ Fallback deletion also failed:', fallbackDeleteError);
                                return { success: false, error: 'Request could not be deleted completely' };
                            } else {
                                console.log('✅ Fallback deletion successful');
                            }
                        } else {
                            console.log('✅ Alternative force delete successful');
                        }
                    } catch (altForceError) {
                        console.error('❌ Alternative force delete error:', altForceError);
                        
                        // Final fallback: try direct deletion
                        console.log('🔄 Attempting final fallback deletion...');
                        try {
                            const { data: finalFallbackData, error: finalFallbackError } = await this.supabase
                                .from('product_requests')
                                .delete()
                                .eq('id', requestId)
                                .select();
                            
                            if (finalFallbackError) {
                                console.error('❌ Final fallback deletion failed:', finalFallbackError);
                                return { success: false, error: 'Request could not be deleted completely' };
                            } else {
                                console.log('✅ Final fallback deletion successful');
                            }
                        } catch (finalFallbackError) {
                            console.error('❌ Final fallback deletion error:', finalFallbackError);
                            return { success: false, error: 'Request could not be deleted completely' };
                        }
                    }
                }
            } else {
                console.log('✅ Request deletion verified successfully');
            }

            console.log('✅ Product request rejected and completely deleted');
            return { success: true };
        } catch (error) {
            console.error('Error in rejectProductRequest:', error);
            return { success: false, error: error.message };
        }
    }

    // Move images from temporary to final location using existing folder structure
    async moveImagesToFinalLocation(imageUrls, category) {
        try {
            if (!imageUrls || imageUrls.length === 0) {
                return [];
            }

            const finalImageUrls = [];
            const timestamp = Date.now();
            const successfullyCopiedImages = []; // لتتبع الصور التي نُسخت بنجاح

            // Map category to existing folder structure
            const folderMap = {
                'cake': 'products_cake',
                'koshat': 'products_koshat',
                'mirr': 'products_mirr',
                'other': 'products_other',
                'invitations': 'products_invitations'
            };

            const folderPath = folderMap[category] || 'products_other';
            console.log(`🎯 Moving images to existing folder: ${folderPath}`);

            for (let i = 0; i < imageUrls.length; i++) {
                const image = imageUrls[i];
                const fileName = `product_${category}_${timestamp}_${i}_${image.original_name}`;
                const finalPath = `${folderPath}/${fileName}`;

                console.log(`🔄 Moving image to final location: ${finalPath}`);

                // Copy file to final location
                const { data: copyData, error: copyError } = await this.supabase.storage
                    .from('images')
                    .copy(image.path, finalPath);

                if (copyError) {
                    console.error(`Error copying image to final location:`, copyError);
                    // Keep original path if copy fails
                    finalImageUrls.push(image.url);
                    continue;
                }

                // Get public URL for final location
                const { data: urlData } = this.supabase.storage
                    .from('images')
                    .getPublicUrl(finalPath);

                if (urlData?.publicUrl) {
                    finalImageUrls.push(urlData.publicUrl);
                    // إضافة الصورة لقائمة الصور الناجحة للحذف لاحقاً
                    successfullyCopiedImages.push({
                        path: image.path,
                        original_name: image.original_name
                    });
                    console.log(`✅ Image moved to existing folder: ${finalPath}`);
                } else {
                    // Fallback to original URL
                    finalImageUrls.push(image.url);
                }
            }

            // 🗑️ حذف الصور الأصلية من مجلد Product_requests بعد نجاح النسخ
            if (successfullyCopiedImages.length > 0) {
                console.log(`🧹 Cleaning up ${successfullyCopiedImages.length} temporary images from Product_requests/`);
                
                for (const image of successfullyCopiedImages) {
                    try {
                        console.log(`🗑️ Deleting temporary image: ${image.path}`);
                        
                        const { error: deleteError } = await this.supabase.storage
                            .from('images')
                            .remove([image.path]);

                        if (deleteError) {
                            console.error(`❌ Failed to delete temporary image ${image.path}:`, deleteError);
                        } else {
                            console.log(`✅ Successfully deleted temporary image: ${image.path}`);
                        }
                    } catch (deleteError) {
                        console.error(`❌ Error deleting temporary image ${image.path}:`, deleteError);
                    }
                }
                
                console.log(`🧹 Cleanup completed. Deleted ${successfullyCopiedImages.length} temporary images.`);
            } else {
                console.log(`⚠️ No images were successfully copied, skipping cleanup.`);
            }

            return finalImageUrls;
        } catch (error) {
            console.error('Error moving images to final location:', error);
            // Return original URLs as fallback
            return imageUrls.map(img => img.url);
        }
    }

    // Get table name based on category
    getTableName(category) {
        const tableMap = {
            'cake': 'products_cake',
            'koshat': 'products_koshat', 
            'mirr': 'products_mirr',
            'other': 'products_other',
            'invitations': 'products_invitations'
        };
        
        const tableName = tableMap[category];
        if (!tableName) {
            console.warn(`⚠️ Unknown category: ${category}, defaulting to products_other`);
            return 'products_other';
        }
        
        return tableName;
    }

    // Get request statistics
    async getRequestStatistics() {
        try {
            const isReady = await this.ensureInitialized();
            if (!isReady) {
                return { success: false, error: 'ProductRequestsService not initialized' };
            }

            const { data, error } = await this.supabase
                .from('product_requests')
                .select('status');

            if (error) {
                console.error('Error fetching request statistics:', error);
                return { success: false, error: error.message };
            }

            const stats = {
                total: data.length,
                pending: data.filter(r => r.status === 'pending').length,
                approved: data.filter(r => r.status === 'approved').length,
                rejected: data.filter(r => r.status === 'rejected').length
            };

            return { success: true, data: stats };
        } catch (error) {
            console.error('Error in getRequestStatistics:', error);
            return { success: false, error: error.message };
        }
    }

    // Delete images from storage when rejecting a request
    async deleteRequestImages(imageUrls) {
        try {
            if (!imageUrls || imageUrls.length === 0) {
                return;
            }

            console.log(`🗑️ Deleting ${imageUrls.length} images from storage`);

            for (let i = 0; i < imageUrls.length; i++) {
                const image = imageUrls[i];
                const imagePath = image.path || image.url;

                if (imagePath) {
                    try {
                        // Extract path from URL if it's a full URL
                        let storagePath = imagePath;
                        if (imagePath.startsWith('http')) {
                            // Extract path from URL (remove domain and bucket)
                            const urlParts = imagePath.split('/');
                            const pathIndex = urlParts.findIndex(part => part === 'images');
                            if (pathIndex !== -1) {
                                storagePath = urlParts.slice(pathIndex + 1).join('/');
                            }
                        }

                        if (storagePath && !storagePath.startsWith('http')) {
                            const { error: deleteError } = await this.supabase.storage
                                .from('images')
                                .remove([storagePath]);

                            if (deleteError) {
                                console.warn(`⚠️ Could not delete image ${storagePath}:`, deleteError);
                            } else {
                                console.log(`✅ Deleted image: ${storagePath}`);
                            }
                        }
                    } catch (imgError) {
                        console.warn(`⚠️ Error deleting image ${i + 1}:`, imgError);
                    }
                }
            }
        } catch (error) {
            console.error('Error deleting request images:', error);
        }
    }
}

// Make the service available globally
window.ProductRequestsService = ProductRequestsService;
