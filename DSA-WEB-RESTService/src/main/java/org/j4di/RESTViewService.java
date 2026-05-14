package org.j4di;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/analytics")
public class RESTViewService {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @GetMapping("/salesByState")
    public List<Map<String, Object>> getSalesByState() {
        return jdbcTemplate.queryForList("SELECT * FROM OLAP_VIEW_SALES_BY_STATE");
    }

    @GetMapping("/salesByCategory")
    public List<Map<String, Object>> getSalesByCategory() {
        return jdbcTemplate.queryForList("SELECT * FROM OLAP_VIEW_SALES_BY_CATEGORY");
    }

    @GetMapping("/salesRank")
    public List<Map<String, Object>> getSalesRank() {
        return jdbcTemplate.queryForList("SELECT * FROM OLAP_VIEW_SALES_RANK");
    }
}
