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
@RequestMapping("/api/olap/category-ranking")
@Tag(name = "OLAP Window Functions (RANK & OVER)", description = "Analytics using SQL Window Functions to partition and rank data")
public class CategoryRankingWindowController {

    private final JdbcTemplate jdbcTemplate;

    public CategoryRankingWindowController(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @GetMapping("/revenue")
    @Operation(summary = "Windowed Global Average Comparison", description = "It calculates the total revenue for every product category, then uses AVG() OVER() to broadcast the overall average category revenue to all rows. It finally calculates how far each category is above or below the global average.")
    public List<Map<String, Object>> getCategoryRanking() {
        String sql = "SELECT " +
                "    category AS product_category, " +
                "    ROUND(SUM(price + freight_value), 2) AS category_revenue, " +
                "    ROUND(AVG(SUM(price + freight_value)) OVER (), 2) AS avg_global_category_revenue, " +
                "    ROUND(SUM(price + freight_value) - AVG(SUM(price + freight_value)) OVER (), 2) AS difference_from_avg "
                +
                "FROM " +
                "    vw_consolidated_orders " +
                "WHERE " +
                "    order_status = 'delivered' AND category IS NOT NULL " +
                "GROUP BY " +
                "    category " +
                "ORDER BY " +
                "    category_revenue DESC";

        return jdbcTemplate.queryForList(sql);
    }
}
