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
@RequestMapping("/api/sellers")
@Tag(name = "Seller Analytics", description = "Endpoints for seller-based analytical queries")
public class SellerAnalyticsController {

    private final JdbcTemplate jdbcTemplate;

    public SellerAnalyticsController(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @GetMapping("/freight")
    @Operation(summary = "Get average freight value by seller city", description = "Calculates the average freight (transport) cost for each seller city.")
    public List<Map<String, Object>> getAvgFreightBySellerCity() {
        String sql = "SELECT seller_city, AVG(freight_value) as avg_freight " +
                     "FROM vw_consolidated_orders " +
                     "WHERE seller_city IS NOT NULL " +
                     "GROUP BY seller_city " +
                     "ORDER BY avg_freight DESC " +
                     "FETCH FIRST 50 ROWS ONLY";
        return jdbcTemplate.queryForList(sql);
    }
}
