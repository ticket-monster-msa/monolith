/*
 * Copyright 2012-2017 the original author or authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.ticketmonster.orders.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.boot.autoconfigure.jdbc.DataSourceBuilder;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.Resource;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.datasource.DriverManagerDataSource;
import org.springframework.jdbc.datasource.init.DatabasePopulator;
import org.springframework.jdbc.datasource.init.DatabasePopulatorUtils;
import org.springframework.jdbc.datasource.init.ResourceDatabasePopulator;

import javax.sql.DataSource;

@Configuration
@Profile({"!mysql", "!kube"})
public class TeiidTestDataSources {

    @Bean
    public DataSource legacyDS() {

        DataSource dataSource = DataSourceBuilder.create().driverClassName("org.h2.Driver").username("sa").password("").url("jdbc:h2:mem:legacydb;DB_CLOSE_ON_EXIT=FALSE;DATABASE_TO_UPPER=FALSE;MODE=MYSQL").build();

        Resource initSchema = new ClassPathResource("h2/scripts/legacydb-schema.sql");
        Resource initData = new ClassPathResource("h2/scripts/legacydb-data.sql");
        DatabasePopulator databasePopulator = new ResourceDatabasePopulator(initSchema, initData);
        DatabasePopulatorUtils.execute(databasePopulator, dataSource);
        return dataSource;
    }
    
    @Bean
    public DataSource ordersDS() {
        DataSource dataSource = DataSourceBuilder.create().driverClassName("org.h2.Driver").username("sa").password("").url("jdbc:h2:mem:ordersdb;DB_CLOSE_ON_EXIT=FALSE;DATABASE_TO_UPPER=FALSE;MODE=MYSQL").build();

        Resource initSchema = new ClassPathResource("h2/scripts/ordersdb-schema.sql");
        Resource initData = new ClassPathResource("h2/scripts/ordersdb-data.sql");
        DatabasePopulator databasePopulator = new ResourceDatabasePopulator(initSchema, initData);
        DatabasePopulatorUtils.execute(databasePopulator, dataSource);
        return dataSource;
    }

    @Bean
    @Autowired
    public JdbcTemplate teiidJdbcTemplate(@Qualifier("dataSource") DataSource dataSource) {
        JdbcTemplate tc = new JdbcTemplate(dataSource);
        return tc;
    }
}
