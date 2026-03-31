package com.example.fdb_api.controller;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/olap/customer-seller")
@Tag(name = "OLAP Customer & Seller (CUBE)", description = "CUBE Analytics crossing Customer Regions with Seller Regions")
public class CustomerSellerCubeController {

    private final JdbcTemplate jdbcTemplate;

    public CustomerSellerCubeController(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @GetMapping("/revenue")
    @Operation(summary = "CUBE Analytics", description = "Generates cross-tabulation for buyer & seller states. Regular Rows: Customer & Seller. Customer Totals (seller null). Seller Totals (customer null). Grand Total (both null).")
    public List<Map<String, Object>> getCustomerSellerCube() {
        String sql = "SELECT customer_state, seller_state, " +
                     "COUNT(order_id) AS total_orders, " +
                     "ROUND(SUM(price + freight_value), 2) AS total_revenue " +
                     "FROM vw_consolidated_orders " +
                     "WHERE order_status = 'delivered' " +
                     "GROUP BY CUBE(customer_state, seller_state) " +
                     "ORDER BY customer_state NULLS LAST, seller_state NULLS LAST";
        return jdbcTemplate.queryForList(sql);
    }
}
