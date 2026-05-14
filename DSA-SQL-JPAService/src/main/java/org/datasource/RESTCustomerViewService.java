package org.datasource;

import org.datasource.springdata.views.CustomerView;
import org.datasource.springdata.views.CustomerViewRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/customers")
public class RESTCustomerViewService {

    @Autowired
    private CustomerViewRepository customerRepository;

    @GetMapping("/CustomerView")
    public List<CustomerView> getCustomers() {
        return customerRepository.findAll();
    }
}
