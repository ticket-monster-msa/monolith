package org.jboss.examples.ticketmonster.rest;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.inject.Inject;
import javax.persistence.EntityManager;
import javax.persistence.TypedQuery;
import javax.persistence.criteria.CriteriaBuilder;
import javax.persistence.criteria.CriteriaQuery;
import javax.persistence.criteria.Predicate;
import javax.persistence.criteria.Root;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.MultivaluedMap;
import javax.ws.rs.core.UriInfo;

/**
 * <p>
 *   A number of RESTful services implement GET operations on a particular type of entity. For
 *   observing the DRY principle, the generic operations are implemented in the <code>BaseEntityService</code>
 *   class, and the other services can inherit from here.
 * </p>
 *
 * <p>
 *    Subclasses will declare a base path using the JAX-RS {@link Path} annotation, for example:
 * </p>
 *
 * <pre>
 * <code>
 * &#064;Path("/widgets")
 * public class WidgetService extends BaseEntityService<Widget> {
 * ...
 * }
 * </code>
 * </pre>
 *
 * <p>
 *   will support the following methods:
 * </p>
 *
 * <pre>
 * <code>
 *   GET /widgets
 *   GET /widgets/:id
 *   GET /widgets/count
 * </code>
 * </pre>
 *
 *  <p>
 *     Subclasses may specify various criteria for filtering entities when retrieving a list of them, by supporting
 *     custom query parameters. Pagination is supported by default through the query parameters <code>first</code>
 *     and <code>maxResults</code>.
 * </p>
 *
 * <p>
 *     The class is abstract because it is not intended to be used directly, but subclassed by actual JAX-RS
 *     endpoints.
 * </p>
 *

 * @author Marius Bogoevici
 */
public abstract class BaseEntityService<T> {

    @Inject
    private EntityManager entityManager;

    private Class<T> entityClass;

    public BaseEntityService() {}
    
    public BaseEntityService(Class<T> entityClass) {
        this.entityClass = entityClass;
    }

    public EntityManager getEntityManager() {
        return entityManager;
    }

    /**
     * <p>
     *   A method for retrieving all entities of a given type. Supports the query parameters <code>first</code>
     *   and <code>maxResults</code> for pagination.
     * </p>
     *
     * @param uriInfo application and request context information (see {@see UriInfo} class information for more details)
     * @return
     */
    @GET
    @Produces(MediaType.APPLICATION_JSON)
    public List<T> getAll(@Context UriInfo uriInfo) {
        return getAll(uriInfo.getQueryParameters());
    }
    
    public List<T> getAll(MultivaluedMap<String, String> queryParameters) {
        final CriteriaBuilder criteriaBuilder = entityManager.getCriteriaBuilder();
        final CriteriaQuery<T> criteriaQuery = criteriaBuilder.createQuery(entityClass);
        Root<T> root = criteriaQuery.from(entityClass);
        Predicate[] predicates = extractPredicates(queryParameters, criteriaBuilder, root);
        criteriaQuery.select(criteriaQuery.getSelection()).where(predicates);
        criteriaQuery.orderBy(criteriaBuilder.asc(root.get("id")));
        TypedQuery<T> query = entityManager.createQuery(criteriaQuery);
        if (queryParameters.containsKey("first")) {
        	Integer firstRecord = Integer.parseInt(queryParameters.getFirst("first"))-1;
        	query.setFirstResult(firstRecord);
        }
        if (queryParameters.containsKey("maxResults")) {
        	Integer maxResults = Integer.parseInt(queryParameters.getFirst("maxResults"));
        	query.setMaxResults(maxResults);
        }
		return query.getResultList();
    }

    /**
     * <p>
     *   A method for counting all entities of a given type
     * </p>
     *
     * @param uriInfo application and request context information (see {@see UriInfo} class information for more details)
     * @return
     */
    @GET
    @Path("/count")
    @Produces(MediaType.APPLICATION_JSON)
    public Map<String, Long> getCount(@Context UriInfo uriInfo) {
        CriteriaBuilder criteriaBuilder = entityManager.getCriteriaBuilder();
        CriteriaQuery<Long> criteriaQuery = criteriaBuilder.createQuery(Long.class);
        Root<T> root = criteriaQuery.from(entityClass);
        criteriaQuery.select(criteriaBuilder.count(root));
        Predicate[] predicates = extractPredicates(uriInfo.getQueryParameters(), criteriaBuilder, root);
        criteriaQuery.where(predicates);
        Map<String, Long> result = new HashMap<String, Long>();
        result.put("count", entityManager.createQuery(criteriaQuery).getSingleResult());
        return result;
    }

    /**
     * <p>
     *     Subclasses may choose to expand the set of supported query parameters (for adding more filtering
     *     criteria on search and count) by overriding this method.
     * </p>
     * @param queryParameters - the HTTP query parameters received by the endpoint
     * @param criteriaBuilder - @{link CriteriaBuilder} used by the invoker
     * @param root  @{link Root} used by the invoker
     * @return a list of {@link Predicate}s that will added as query parameters
     */
    protected Predicate[] extractPredicates(MultivaluedMap<String, String> queryParameters, CriteriaBuilder criteriaBuilder, Root<T> root) {
        return new Predicate[]{};
    }

    /**
     * <p>
     *     A method for retrieving individual entity instances.
     * </p>
     * @param id entity id
     * @return
     */
    @GET
    @Path("/{id:[0-9][0-9]*}")
    @Produces(MediaType.APPLICATION_JSON)
    public T getSingleInstance(@PathParam("id") Long id) {
        final CriteriaBuilder criteriaBuilder = entityManager.getCriteriaBuilder();
        final CriteriaQuery<T> criteriaQuery = criteriaBuilder.createQuery(entityClass);
        Root<T> root = criteriaQuery.from(entityClass);
        Predicate condition = criteriaBuilder.equal(root.get("id"), id);
        criteriaQuery.select(criteriaBuilder.createQuery(entityClass).getSelection()).where(condition);
        return entityManager.createQuery(criteriaQuery).getSingleResult();
    }
}
