package org.datasource;

import org.datasource.springdata.views.SellerView;
import org.datasource.springdata.views.SellerViewRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/sellers")
public class RESTSellerViewService {

    @Autowired
    private SellerViewRepository sellerRepository;

    @GetMapping("/SellerView")
    public List<SellerView> getSellers() {
        return sellerRepository.findAll();
    }
}
