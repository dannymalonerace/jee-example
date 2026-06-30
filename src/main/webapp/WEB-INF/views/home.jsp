<%@ include file="layout/header.jspf" %>
<section class="text-center pt-6 sm:pt-12">
  <span class="inline-flex items-center gap-1.5 rounded-full bg-indigo-50 px-3 py-1 text-xs font-medium text-indigo-700 ring-1 ring-inset ring-indigo-200 mb-6">
    <span class="h-1.5 w-1.5 rounded-full bg-indigo-500"></span>
    Jakarta EE 10 starter
  </span>
  <h1 class="text-5xl sm:text-6xl font-extrabold tracking-tight">
    <span class="bg-clip-text text-transparent bg-gradient-to-r from-indigo-600 via-violet-600 to-purple-600">Hello, World</span>
  </h1>
  <p class="mt-5 text-lg text-slate-600 max-w-xl mx-auto">
    A small server-rendered web app on WildFly + MySQL. Add a greeting, see it persist, watch the layered architecture do its thing.
  </p>
  <div class="mt-8 flex items-center justify-center gap-3">
    <a href="${pageContext.request.contextPath}/greetings/new"
       class="inline-flex items-center gap-2 bg-indigo-600 hover:bg-indigo-700 text-white px-5 py-2.5 rounded-lg shadow-sm font-medium transition-colors focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2">
      <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" viewBox="0 0 20 20" fill="currentColor"><path d="M10 5a1 1 0 0 1 1 1v3h3a1 1 0 1 1 0 2h-3v3a1 1 0 1 1-2 0v-3H6a1 1 0 1 1 0-2h3V6a1 1 0 0 1 1-1Z"/></svg>
      New Greeting
    </a>
    <a href="${pageContext.request.contextPath}/greetings"
       class="inline-flex items-center gap-2 bg-white hover:bg-slate-50 text-slate-700 px-5 py-2.5 rounded-lg border border-slate-200 shadow-sm font-medium transition-colors focus:outline-none focus:ring-2 focus:ring-slate-300 focus:ring-offset-2">
      View greetings
      <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M7.293 14.707a1 1 0 0 1 0-1.414L10.586 10 7.293 6.707a1 1 0 1 1 1.414-1.414l4 4a1 1 0 0 1 0 1.414l-4 4a1 1 0 0 1-1.414 0Z" clip-rule="evenodd"/></svg>
    </a>
  </div>
</section>

<section class="grid sm:grid-cols-3 gap-4 pt-4">
  <div class="rounded-xl border border-slate-200 bg-white p-5 shadow-sm">
    <div class="text-xs uppercase tracking-wider text-slate-500 font-semibold">Layered</div>
    <div class="mt-1 font-medium text-slate-900">Servlet &rarr; Service &rarr; Repository</div>
    <p class="mt-1 text-sm text-slate-600">Clean handoff between request handling, business rules, and persistence.</p>
  </div>
  <div class="rounded-xl border border-slate-200 bg-white p-5 shadow-sm">
    <div class="text-xs uppercase tracking-wider text-slate-500 font-semibold">Migrated</div>
    <div class="mt-1 font-medium text-slate-900">Flyway-versioned schema</div>
    <p class="mt-1 text-sm text-slate-600">No <code class="font-mono text-xs bg-slate-100 rounded px-1">hbm2ddl=update</code>. Hibernate just trusts the schema.</p>
  </div>
  <div class="rounded-xl border border-slate-200 bg-white p-5 shadow-sm">
    <div class="text-xs uppercase tracking-wider text-slate-500 font-semibold">Tested</div>
    <div class="mt-1 font-medium text-slate-900">Real MySQL via Testcontainers</div>
    <p class="mt-1 text-sm text-slate-600">Repository &amp; HTTP integration tests run against a real WildFly + MySQL stack.</p>
  </div>
</section>
<%@ include file="layout/footer.jspf" %>
