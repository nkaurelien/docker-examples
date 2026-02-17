<#import "template.ftl" as layout>
<@layout.emailLayout>
  <h2>${msg("emailVerificationSubject")}</h2>
  <p>${msg("emailVerificationBody", link, linkExpiration, realmName, linkExpirationFormatter(linkExpiration))}</p>
  <p style="text-align: center;">
    <a href="${link}" class="btn">${msg("emailVerificationLinkText")}</a>
  </p>
  <p style="font-size: 12px; color: #999;">${msg("emailVerificationBodyCode", code)}</p>
</@layout.emailLayout>
