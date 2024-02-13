package org.ticketmonster.orders.booking;


import org.ticketmonster.orders.domain.Section;

import java.util.Comparator;

/**
 * A utility comparator for sections, sorting them by id
 *
* @author Marius Bogoevici
*/
public class SectionComparator implements Comparator<Section> {

    private static final SectionComparator INSTANCE = new SectionComparator();

    private SectionComparator(){
    }

    public static SectionComparator instance() {
        return INSTANCE;
    }

    @Override
    public int compare(Section section, Section otherSection) {
        return section.getId().compareTo(otherSection.getId());
    }

}
