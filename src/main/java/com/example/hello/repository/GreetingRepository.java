package com.example.hello.repository;

import com.example.hello.entity.Greeting;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;

import java.util.List;

@ApplicationScoped
public class GreetingRepository {

    @PersistenceContext(unitName = "helloPU")
    private EntityManager em;

    public GreetingRepository() {
    }

    GreetingRepository(EntityManager em) {
        this.em = em;
    }

    public Greeting save(Greeting greeting) {
        if (greeting.getId() == null) {
            em.persist(greeting);
            return greeting;
        }
        return em.merge(greeting);
    }

    public List<Greeting> findAllNewestFirst() {
        return em.createQuery(
                        "SELECT g FROM Greeting g ORDER BY g.createdAt DESC, g.id DESC",
                        Greeting.class)
                .getResultList();
    }
}
