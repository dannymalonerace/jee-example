<%@ include file="layout/header.jspf" %>
<section class="space-y-6">
  <div>
    <h1 class="text-3xl font-bold tracking-tight">About</h1>
    <p class="text-sm text-slate-600 mt-1">A small Jakarta EE 10 starter on WildFly + MySQL.</p>
  </div>

  <div class="rounded-2xl border border-slate-200 bg-white shadow-sm p-6 sm:p-8 space-y-6">
    <div>
      <h2 class="text-sm font-semibold uppercase tracking-wider text-slate-500">Stack</h2>
      <div class="mt-3 flex flex-wrap gap-2">
        <span class="inline-flex items-center px-2.5 py-1 rounded-md bg-slate-100 text-slate-700 text-xs font-medium font-mono">Java 17</span>
        <span class="inline-flex items-center px-2.5 py-1 rounded-md bg-slate-100 text-slate-700 text-xs font-medium font-mono">Jakarta EE 10</span>
        <span class="inline-flex items-center px-2.5 py-1 rounded-md bg-slate-100 text-slate-700 text-xs font-medium font-mono">WildFly 30</span>
        <span class="inline-flex items-center px-2.5 py-1 rounded-md bg-slate-100 text-slate-700 text-xs font-medium font-mono">MySQL 8</span>
        <span class="inline-flex items-center px-2.5 py-1 rounded-md bg-slate-100 text-slate-700 text-xs font-medium font-mono">Hibernate 6</span>
        <span class="inline-flex items-center px-2.5 py-1 rounded-md bg-slate-100 text-slate-700 text-xs font-medium font-mono">Flyway 10</span>
        <span class="inline-flex items-center px-2.5 py-1 rounded-md bg-slate-100 text-slate-700 text-xs font-medium font-mono">JSP + JSTL</span>
        <span class="inline-flex items-center px-2.5 py-1 rounded-md bg-indigo-50 text-indigo-700 text-xs font-medium font-mono ring-1 ring-inset ring-indigo-200">Tailwind CSS</span>
      </div>
    </div>

    <div>
      <h2 class="text-sm font-semibold uppercase tracking-wider text-slate-500">Architecture</h2>
      <p class="mt-2 text-sm text-slate-700 leading-relaxed">
        Layering goes <span class="font-mono text-xs bg-slate-100 rounded px-1.5 py-0.5">Servlet</span> &rarr;
        <span class="font-mono text-xs bg-slate-100 rounded px-1.5 py-0.5">Service (CDI + @Transactional)</span> &rarr;
        <span class="font-mono text-xs bg-slate-100 rounded px-1.5 py-0.5">Repository (JPA)</span> &rarr;
        <span class="font-mono text-xs bg-slate-100 rounded px-1.5 py-0.5">Entity</span>.
        Bean Validation runs in the service layer; servlets handle POST-Redirect-GET. JSPs only render &mdash; no business logic, no DB calls.
      </p>
    </div>

    <div>
      <h2 class="text-sm font-semibold uppercase tracking-wider text-slate-500">Tests</h2>
      <ul class="mt-2 text-sm text-slate-700 space-y-1.5 list-disc list-inside">
        <li>JUnit 5 + Mockito unit tests for the service layer</li>
        <li>Real MySQL 8 via Testcontainers for repository ITs</li>
        <li>Full HTTP ITs that build the project Dockerfile and drive REST-assured</li>
        <li>JaCoCo gate at 80% line coverage on service + web</li>
      </ul>
    </div>

    <div class="pt-4 border-t border-slate-100">
      <p class="text-xs text-slate-500">
        See the project <code class="font-mono bg-slate-100 rounded px-1.5 py-0.5">README.md</code> and
        <code class="font-mono bg-slate-100 rounded px-1.5 py-0.5">CLAUDE.md</code> for the full layout and conventions.
      </p>
    </div>
  </div>
</section>
<%@ include file="layout/footer.jspf" %>
