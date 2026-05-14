package org.datasource.mongodb.views.departamentscities;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;
import java.util.List;

@JsonIgnoreProperties("none")
@Data @AllArgsConstructor @NoArgsConstructor(force = true)
public class DepartamentView implements Serializable{
	private Long idDepartament;
	private String departamentName;
	private String departamentCode;
	private String countryName;

	private List<CityView> cities;

	public Long getIdDepartament() { return idDepartament; }
	public void setIdDepartament(Long idDepartament) { this.idDepartament = idDepartament; }
	public String getDepartamentName() { return departamentName; }
	public void setDepartamentName(String departamentName) { this.departamentName = departamentName; }
	public String getDepartamentCode() { return departamentCode; }
	public void setDepartamentCode(String departamentCode) { this.departamentCode = departamentCode; }
	public String getCountryName() { return countryName; }
	public void setCountryName(String countryName) { this.countryName = countryName; }
	public List<CityView> getCities() { return cities; }
	public void setCities(List<CityView> cities) { this.cities = cities; }
}


