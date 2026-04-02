package com.civilink.civilink;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.ConfigurationPropertiesScan;

@SpringBootApplication
@ConfigurationPropertiesScan
public class CivilinkApplication {

	public static void main(String[] args) {
		SpringApplication.run(CivilinkApplication.class, args);
	}

}

