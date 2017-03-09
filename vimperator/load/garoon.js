(function () {
  commands.addUserCommand(
    ['garoon'],
    'Search garoon',
    function(args) {
      if (!args) return;
      var text = args.string;
      var url = "https://garoon.voyagegroup.com/grn.exe/schedule/index?type=user&search_text=" + text + "&gid=search";
      liberator.open(url);
    }
  );
})();
