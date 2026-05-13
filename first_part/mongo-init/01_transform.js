// ============================================================
// MongoDB: Build nested products collection
// Run via: mongosh --quiet /data/import/01_transform.js
//
// Merges products_raw with category_translation to create
// a single 'products' collection containing the English
// category name as a nested field, then drops staging data.
// ============================================================

db = db.getSiblingDB('olist_db');

db.products_raw.aggregate([
    {
        $lookup: {
            from: "category_translation",
            localField: "product_category_name",
            foreignField: "product_category_name",
            as: "translation"
        }
    },
    {
        $addFields: {
            product_category_name_english: {
                $arrayElemAt: ["$translation.product_category_name_english", 0]
            }
        }
    },
    {
        $project: { translation: 0 }
    },
    { $out: "products" }
]);

// Drop staging collections
db.products_raw.drop();
db.category_translation.drop();
