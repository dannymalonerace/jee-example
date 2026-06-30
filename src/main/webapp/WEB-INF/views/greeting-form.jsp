<%@ include file="layout/header.jspf" %>
<section class="space-y-6">
  <div>
    <h1 class="text-3xl font-bold tracking-tight">New Greeting</h1>
    <p class="text-sm text-slate-600 mt-1">Add a name and a short message. Bean Validation runs on submit.</p>
  </div>

  <c:if test="${errors.hasErrors()}">
    <div class="rounded-lg border border-rose-200 bg-rose-50 px-4 py-3 text-sm text-rose-800 flex items-start gap-2">
      <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mt-0.5 flex-shrink-0 text-rose-500" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M18 10a8 8 0 1 1-16 0 8 8 0 0 1 16 0Zm-8-5a1 1 0 0 0-1 1v4a1 1 0 1 0 2 0V6a1 1 0 0 0-1-1Zm0 8a1 1 0 1 0 0 2 1 1 0 0 0 0-2Z" clip-rule="evenodd"/></svg>
      <div>
        <div class="font-semibold">Please fix the errors below.</div>
        <div class="text-xs text-rose-700 mt-0.5">Your input has been kept.</div>
      </div>
    </div>
  </c:if>

  <form method="post" action="${pageContext.request.contextPath}/greetings/new" novalidate
        class="rounded-2xl border border-slate-200 bg-white shadow-sm p-6 sm:p-8 space-y-6">

    <div>
      <label for="name" class="block text-sm font-medium text-slate-900">Name</label>
      <p class="text-xs text-slate-500 mt-0.5">Up to 100 characters.</p>
      <input type="text" id="name" name="name" maxlength="100" required
             value="<c:out value='${form.name}'/>"
             class="mt-2 block w-full rounded-lg border ${errors.has('name') ? 'border-rose-500 bg-rose-50 focus:ring-rose-500 focus:border-rose-500' : 'border-slate-300 focus:ring-indigo-500 focus:border-indigo-500'} px-3 py-2 text-sm shadow-sm focus:outline-none focus:ring-2 transition-colors">
      <c:if test="${errors.has('name')}">
        <span class="error mt-1.5 block text-sm text-rose-600 flex items-center gap-1" data-field="name">
          <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 flex-shrink-0" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M18 10a8 8 0 1 1-16 0 8 8 0 0 1 16 0Zm-7-4a1 1 0 1 0-2 0v4a1 1 0 1 0 2 0V6Zm-1 8a1 1 0 1 1 0-2 1 1 0 0 1 0 2Z" clip-rule="evenodd"/></svg>
          <c:out value="${errors.get('name')}"/>
        </span>
      </c:if>
    </div>

    <div>
      <label for="message" class="block text-sm font-medium text-slate-900">Message</label>
      <p class="text-xs text-slate-500 mt-0.5">Up to 500 characters.</p>
      <textarea id="message" name="message" maxlength="500" rows="4" required
                class="mt-2 block w-full rounded-lg border ${errors.has('message') ? 'border-rose-500 bg-rose-50 focus:ring-rose-500 focus:border-rose-500' : 'border-slate-300 focus:ring-indigo-500 focus:border-indigo-500'} px-3 py-2 text-sm shadow-sm focus:outline-none focus:ring-2 transition-colors resize-y"><c:out value="${form.message}"/></textarea>
      <c:if test="${errors.has('message')}">
        <span class="error mt-1.5 block text-sm text-rose-600 flex items-center gap-1" data-field="message">
          <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 flex-shrink-0" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M18 10a8 8 0 1 1-16 0 8 8 0 0 1 16 0Zm-7-4a1 1 0 1 0-2 0v4a1 1 0 1 0 2 0V6Zm-1 8a1 1 0 1 1 0-2 1 1 0 0 1 0 2Z" clip-rule="evenodd"/></svg>
          <c:out value="${errors.get('message')}"/>
        </span>
      </c:if>
    </div>

    <div class="flex items-center gap-3 pt-2 border-t border-slate-100">
      <button type="submit"
              class="inline-flex items-center gap-2 bg-indigo-600 hover:bg-indigo-700 text-white px-4 py-2 rounded-lg shadow-sm text-sm font-medium transition-colors focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2">
        Save greeting
      </button>
      <a href="${pageContext.request.contextPath}/greetings"
         class="text-sm text-slate-600 hover:text-slate-900 px-3 py-2 rounded-md transition-colors">
        Cancel
      </a>
    </div>
  </form>
</section>
<%@ include file="layout/footer.jspf" %>
