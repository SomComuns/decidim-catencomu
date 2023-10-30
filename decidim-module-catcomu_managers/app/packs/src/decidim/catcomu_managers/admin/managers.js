$(() => {
  $(".civicrm-sync-group-edit").on("click", (event) => {
    event.preventDefault();
    $(event.delegateTarget).prev().attr("disabled", false);
  });
  
  $(".civicrm-sync-group-select").on("change", (event) => {
    let $select = $(event.delegateTarget);
    /* eslint-disable camelcase */
    $.ajax({
      url: "/admin/managers/scoped_admins",
      data: {
        participatory_process_id: $select.closest("tr").data("participatory_process_id"),
        civicrm_group_id: $select.val()
      },
      method: "POST"
    });
    $select.attr("disabled", true);
  });
});
