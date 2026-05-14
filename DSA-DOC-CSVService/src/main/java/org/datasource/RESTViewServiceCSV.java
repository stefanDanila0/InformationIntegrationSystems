package org.datasource;

import org.datasource.csv.olist.OrderCSVViewBuilder;
import org.datasource.csv.olist.OrderView;
import org.datasource.csv.olist.OrderItemCSVViewBuilder;
import org.datasource.csv.olist.OrderItemView;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/orders")
public class RESTViewServiceCSV {

    @Autowired
    private OrderCSVViewBuilder orderBuilder;

    @Autowired
    private OrderItemCSVViewBuilder orderItemBuilder;

    @GetMapping("/OrderView")
    public List<OrderView> getOrders() throws Exception {
        return orderBuilder.build().getViewList();
    }

    @GetMapping("/OrderItemView")
    public List<OrderItemView> getOrderItems() throws Exception {
        return orderItemBuilder.build().getViewList();
    }
}
