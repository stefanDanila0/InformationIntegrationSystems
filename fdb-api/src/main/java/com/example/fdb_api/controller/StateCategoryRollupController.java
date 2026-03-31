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
@RequestMapping("/api/olap/state-category")
@Tag(name = "OLAP State & Category (ROLLUP)", description = "ROLLUP Analytics for Customer States and Product Categories")
public class StateCategoryRollupController {

    private final JdbcTemplate jdbcTemplate;

    public StateCategoryRollupController(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @GetMapping("/revenue")
    @Operation(summary = "ROLLUP Analytics", description = "Generates sub-totals and grand totals for revenue per state and category. Regular Rows: Revenue for State & Category. Subtotals (category is null): Total for that State. Grand Total (both null): Total across all.")
    public List<Map<String, Object>> getStateCategoryRollup() {
        String sql = "SELECT customer_state, category AS product_category, " +
                     "COUNT(order_id) AS total_orders, " +
                     "ROUND(SUM(price + freight_value), 2) AS total_revenue " +
                     "FROM vw_consolidated_orders " +
                     "WHERE order_status = 'delivered' " +
                     "GROUP BY ROLLUP(customer_state, category) " +
                     "ORDER BY customer_state NULLS LAST, total_revenue DESC";
        return jdbcTemplate.queryForList(sql);
    }
}
