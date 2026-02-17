<#import "template.ftl" as layout>
<@layout.emailLayout>
  <h2>${msg("passwordResetSubject")}</h2>
  <p>${msg("passwordResetBody", link, linkExpiration, realmName, linkExpirationFormatter(linkExpiration))}</p>
  <p style="text-align: center;">
    <a href="${link}" class="btn">${msg("passwordResetLinkText")}</a>
  </p>
</@layout.emailLayout>
