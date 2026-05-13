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
@RequestMapping("/api/categories")
@Tag(name = "Category Analytics", description = "Endpoints for category-based analytical queries")
public class CategoryAnalyticsController {

    private final JdbcTemplate jdbcTemplate;

    public CategoryAnalyticsController(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @GetMapping("/revenue")
    @Operation(summary = "Get top categories by total revenue", description = "Calculates the total revenue for each product category based on the consolidated FDB view.")
    public List<Map<String, Object>> getTopCategoriesByRevenue() {
        String sql = "SELECT category, SUM(price) as total_revenue " +
                "FROM vw_consolidated_orders " +
                "WHERE category IS NOT NULL " +
                "GROUP BY category " +
                "ORDER BY total_revenue DESC " +
                "FETCH FIRST 50 ROWS ONLY";
        return jdbcTemplate.queryForList(sql);
    }
}
