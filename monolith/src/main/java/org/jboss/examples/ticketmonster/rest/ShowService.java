package org.jboss.examples.ticketmonster.rest;

import java.util.ArrayList;
import java.util.List;

import javax.ejb.Stateless;
import javax.persistence.Query;
import javax.persistence.criteria.CriteriaBuilder;
import javax.persistence.criteria.Predicate;
import javax.persistence.criteria.Root;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.MultivaluedMap;

import org.jboss.examples.ticketmonster.model.Show;

/**
 * @author Marius Bogoevici
 */
@Path("/shows")
/**
 * <p>
 *     This is a stateless service, we declare it as an EJB for transaction demarcation
 * </p>
 */
@Stateless
public class ShowService extends BaseEntityService<Show> {

    public ShowService() {
        super(Show.class);
    }

    @Override
    protected Predicate[] extractPredicates(MultivaluedMap<String,
            String> queryParameters,
            CriteriaBuilder criteriaBuilder,
            Root<Show> root) {

        List<Predicate> predicates = new ArrayList<Predicate>();

        if (queryParameters.containsKey("venue")) {
            String venue = queryParameters.getFirst("venue");
            predicates.add(criteriaBuilder.equal(root.get("venue").get("id"), venue));
        }

        if (queryParameters.containsKey("event")) {
            String event = queryParameters.getFirst("event");
            predicates.add(criteriaBuilder.equal(root.get("event").get("id"), event));
        }
        return predicates.toArray(new Predicate[]{});
    }

    @GET
    @Path("/performance/{performanceId:[0-9][0-9]*}")
    @Produces(MediaType.APPLICATION_JSON)
    public Show getShowByPerformance(@PathParam("performanceId") Long performanceId) {
        Query query = getEntityManager().createQuery("select s from Show s where exists(select p from Performance p where p.show = s and p.id = :performanceId)");
        query.setParameter("performanceId", performanceId);
        return (Show) query.getSingleResult();
    }
}
