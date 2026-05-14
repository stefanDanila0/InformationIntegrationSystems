package org.j4di.analytical.views;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface OLAP_VIEW_SALES_BY_STATE_Repository extends JpaRepository<OLAP_VIEW_SALES_BY_STATE, String> {
}
