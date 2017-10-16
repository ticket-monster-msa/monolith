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
package org.ticketmonster.orders.domain;

import java.lang.reflect.Field;

/**
 * Created by ceposta 
 * <a href="http://christianposta.com/blog>http://christianposta.com/blog</a>.
 */
public class SyntheticBooking extends Booking{

    private boolean synthetic;

    public SyntheticBooking(Booking booking) {
        this.setCancellationCode(booking.getCancellationCode());
        this.setContactEmail(booking.getContactEmail());
        this.setTickets(booking.getTickets());
        this.setPerformanceId(booking.getPerformanceId());
        this.setCreatedOn(booking.getCreatedOn());
        this.synthetic = true;
    }

    public boolean isSynthetic() {
        return synthetic;
    }

    public void setSynthetic(boolean synthetic) {
        this.synthetic = synthetic;
    }


}
