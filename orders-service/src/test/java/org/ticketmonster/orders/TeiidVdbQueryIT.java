/**
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 * <p>
 * http://www.apache.org/licenses/LICENSE-2.0
 * <p>
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.ticketmonster.orders;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.junit4.SpringRunner;
import org.ticketmonster.orders.domain.SectionAllocation;
import org.ticketmonster.orders.domain.TicketPriceGuide;

import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;

/**
 * Created by ceposta 
 * <a href="http://christianposta.com/blog>http://christianposta.com/blog</a>.
 */
@RunWith(SpringRunner.class)
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
public class TeiidVdbQueryIT {

    @PersistenceContext
    private EntityManager entityManager;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Test
    public void testQueryTicketPriceGuideWithEntityManager() {
        Set<Long> priceCategoryIds = new HashSet<>();
        priceCategoryIds.add(4L);
        List<TicketPriceGuide> ticketPriceGuides = entityManager
                .createQuery("select p from TicketPriceGuide p where p.id in :ids", TicketPriceGuide.class)
                .setParameter("ids", priceCategoryIds).getResultList();
        assertFalse(ticketPriceGuides.isEmpty());
        assertEquals(1, ticketPriceGuides.size());
        System.out.println("We got [" + ticketPriceGuides.size() + "] price guides");
        for (TicketPriceGuide ticketPriceGuide : ticketPriceGuides) {
            System.out.println(ticketPriceGuide);
        }
    }

    @Test
    public void testQuerySectionAllocationWithEntityManager() {
        List<SectionAllocation> sectionAllocations = entityManager.createQuery(
                "select s from SectionAllocation s where " +
                        "s.performanceId.id = :performanceId and " +
                        "s.section.id = :sectionId")
                .setParameter("performanceId",1L)
                .setParameter("sectionId", 1L)
                .getResultList();
        for (SectionAllocation sa : sectionAllocations) {
            System.out.println("id: " + sa.getId() + ", performance_id: " +
                    sa.getPerformanceId().getId() +  ", section_id: " +
                    sa.getSection().getId() + ", occupiedCount: " + sa.getOccupiedCount());
        }
        assertEquals(1, sectionAllocations.size());
        assertEquals((Long)1L, sectionAllocations.get(0).getSection().getId());
    }

    @Test
    public void testQueryAllSectionAllocationsWithEntityManager() {

        List<SectionAllocation> sectionAllocations = entityManager.createQuery(
                "select s from SectionAllocation s")
                .getResultList();


        for (SectionAllocation sa : sectionAllocations) {
            System.out.println("id: " + sa.getId() + ", performance_id: " +
                    sa.getPerformanceId().getId() +  ", section_id: " +
                    sa.getSection().getId() + ", occupiedCount: " + sa.getOccupiedCount());
        }
    }
}
