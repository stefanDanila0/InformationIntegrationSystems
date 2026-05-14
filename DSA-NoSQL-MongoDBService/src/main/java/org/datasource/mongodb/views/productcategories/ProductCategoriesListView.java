package org.datasource.mongodb.views.productcategories;

import lombok.Data;
import java.util.List;

@Data
public class ProductCategoriesListView {
    private List<ProductCategoryView> categories;
}
