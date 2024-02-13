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
import org.springframework.jdbc.core.JdbcTemplate;

import javax.sql.DataSource;

@Configuration
@Profile({"mysql", "kube"})
public class TeiidDataSources {

    @ConfigurationProperties(prefix = "spring.datasource.legacyDS")
    @Bean
    public DataSource legacyDS() {
        return DataSourceBuilder.create().build();
    }
    
    @ConfigurationProperties(prefix = "spring.datasource.ordersDS")
    @Bean
    public DataSource ordersDS() {
        return DataSourceBuilder.create().build();
    }

    @Bean
    @Autowired
    public JdbcTemplate teiidJdbcTemplate(@Qualifier("dataSource") DataSource dataSource) {
        JdbcTemplate tc = new JdbcTemplate(dataSource);
        return tc;
    }
}
