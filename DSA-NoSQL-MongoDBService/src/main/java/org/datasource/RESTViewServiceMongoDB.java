package org.datasource;

import org.datasource.mongodb.views.departamentscities.CityView;
import org.datasource.mongodb.views.departamentscities.DepartamentView;
import org.datasource.mongodb.views.departamentscities.DepartamentViewBuilder;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/locations")
public class RESTViewServiceMongoDB {

    @Autowired
    private DepartamentViewBuilder departamentBuilder;

    @Autowired
    private org.datasource.mongodb.views.productcategories.ProductCategoryViewBuilder categoryBuilder;

    @GetMapping("/DepartamentView")
    public List<DepartamentView> getDepartaments() throws Exception {
        return departamentBuilder.build().getDepartamentsViewList();
    }

    @GetMapping("/CityView")
    public List<CityView> getCities() throws Exception {
        return departamentBuilder.build().getCitiesViewList();
    }

    @GetMapping("/ProductCategoryView")
    public List<org.datasource.mongodb.views.productcategories.ProductCategoryView> getProductCategories() throws Exception {
        List<org.datasource.mongodb.views.productcategories.ProductCategoryView> categories = categoryBuilder.build().getCategoryViewList();
        return categories != null ? categories : new java.util.ArrayList<>();
    }
}
