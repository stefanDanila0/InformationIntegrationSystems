package org.datasource;

import org.datasource.jpa.views.product.ProductView;
import org.datasource.jpa.views.product.ProductViewBuilder;
import org.datasource.jpa.views.sales.SalesView;
import org.datasource.jpa.views.sales.SalesViewBuilderSQL;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/sales")
public class RESTViewServiceJPA {

    @Autowired
    private SalesViewBuilderSQL salesBuilder;

    @Autowired
    private ProductViewBuilder productBuilder;

    @GetMapping("/SalesView")
    public List<SalesView> getSales() {
        return salesBuilder.build().getSalesViewList();
    }

    @GetMapping("/ProductView")
    public List<ProductView> getProducts() {
        return productBuilder.build().getProductViewList();
    }
}
