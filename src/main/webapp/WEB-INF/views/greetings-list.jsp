<%@ include file="layout/header.jspf" %>
<section class="space-y-6">
  <div class="flex items-end justify-between gap-4">
    <div>
      <h1 class="text-3xl font-bold tracking-tight">Greetings</h1>
      <p class="text-sm text-slate-600 mt-1">Newest first. Persisted in MySQL via JPA + Flyway.</p>
    </div>
    <a href="${pageContext.request.contextPath}/greetings/new"
       class="hidden sm:inline-flex items-center gap-2 bg-indigo-600 hover:bg-indigo-700 text-white px-4 py-2 rounded-lg shadow-sm text-sm font-medium transition-colors focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2">
      <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" viewBox="0 0 20 20" fill="currentColor"><path d="M10 5a1 1 0 0 1 1 1v3h3a1 1 0 1 1 0 2h-3v3a1 1 0 1 1-2 0v-3H6a1 1 0 1 1 0-2h3V6a1 1 0 0 1 1-1Z"/></svg>
      New Greeting
    </a>
  </div>

  <c:choose>
    <c:when test="${empty greetings}">
      <div class="rounded-2xl border border-dashed border-slate-300 bg-white p-12 text-center">
        <div class="mx-auto h-12 w-12 rounded-full bg-indigo-50 flex items-center justify-center text-indigo-600">
          <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M18 10a8 8 0 1 1-16 0 8 8 0 0 1 16 0Zm-8-3a1 1 0 0 0-1 1v3a1 1 0 1 0 2 0V8a1 1 0 0 0-1-1Zm0 6a1 1 0 1 0 0 2 1 1 0 0 0 0-2Z" clip-rule="evenodd"/></svg>
        </div>
        <h3 class="mt-3 text-base font-semibold text-slate-900">No greetings yet</h3>
        <p class="mt-1 text-sm text-slate-600">Be the first to leave one.</p>
        <a href="${pageContext.request.contextPath}/greetings/new"
           class="mt-5 inline-flex items-center gap-2 bg-indigo-600 hover:bg-indigo-700 text-white px-4 py-2 rounded-lg shadow-sm text-sm font-medium transition-colors focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2">
          Add the first greeting
        </a>
      </div>
    </c:when>
    <c:otherwise>
      <div class="rounded-2xl border border-slate-200 bg-white shadow-sm overflow-hidden">
        <table class="w-full text-sm">
          <thead class="bg-slate-50 text-slate-500">
            <tr>
              <th class="text-left font-medium px-4 py-3">Name</th>
              <th class="text-left font-medium px-4 py-3">Message</th>
              <th class="text-right font-medium px-4 py-3 hidden sm:table-cell">Created</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-slate-100">
            <c:forEach var="g" items="${greetings}">
              <tr class="hover:bg-slate-50/60 transition-colors">
                <td class="px-4 py-3 font-medium text-slate-900"><c:out value="${g.name}"/></td>
                <td class="px-4 py-3 text-slate-700"><c:out value="${g.message}"/></td>
                <td class="px-4 py-3 text-right text-xs font-mono text-slate-500 hidden sm:table-cell">${g.createdAt}</td>
              </tr>
            </c:forEach>
          </tbody>
        </table>
      </div>
      <p class="text-xs text-slate-500"><c:out value="${greetings.size()}"/> total</p>
    </c:otherwise>
  </c:choose>
</section>
<%@ include file="layout/footer.jspf" %>
