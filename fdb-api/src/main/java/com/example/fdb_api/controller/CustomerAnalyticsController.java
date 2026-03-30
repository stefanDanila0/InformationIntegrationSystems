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
@RequestMapping("/api/customers")
@Tag(name = "Customer Analytics", description = "Endpoints for customer-based analytical queries")
public class CustomerAnalyticsController {

    private final JdbcTemplate jdbcTemplate;

    public CustomerAnalyticsController(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @GetMapping("/states")
    @Operation(summary = "Get total orders by customer state", description = "Counts the total number of orders for each customer state.")
    public List<Map<String, Object>> getOrdersByCustomerState() {
        String sql = "SELECT customer_state, COUNT(order_id) as total_orders " +
                     "FROM vw_consolidated_orders " +
                     "WHERE customer_state IS NOT NULL " +
                     "GROUP BY customer_state " +
                     "ORDER BY total_orders DESC";
        return jdbcTemplate.queryForList(sql);
    }
}
