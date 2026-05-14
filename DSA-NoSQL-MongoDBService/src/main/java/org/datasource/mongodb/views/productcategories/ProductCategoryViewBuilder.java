package org.datasource.mongodb.views.productcategories;

import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;
import org.bson.Document;
import org.datasource.mongodb.MongoDataSourceConnector;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
public class ProductCategoryViewBuilder {

    private List<ProductCategoryView> categoryViewList = new ArrayList<>();

    public List<ProductCategoryView> getCategoryViewList() {
        return categoryViewList;
    }

    private MongoDataSourceConnector dataSourceConnector;

    public ProductCategoryViewBuilder(MongoDataSourceConnector dataSourceConnector) {
        this.dataSourceConnector = dataSourceConnector;
    }

    public ProductCategoryViewBuilder build() throws Exception {
        MongoDatabase db = dataSourceConnector.getMongoDatabase();
        MongoCollection<Document> collection = db.getCollection("ProductCategories");
        
        Document doc = collection.find().first();
        this.categoryViewList = new ArrayList<>();
        
        if (doc != null && doc.get("categories") instanceof List) {
            List<Document> categoriesDocs = (List<Document>) doc.get("categories");
            for (Document catDoc : categoriesDocs) {
                this.categoryViewList.add(new ProductCategoryView(
                        catDoc.getString("categoryName"),
                        catDoc.getString("categoryNameEnglish")
                ));
            }
        }
        return this;
    }
}
