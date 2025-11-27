final: prev: {
  zotero = prev.zotero-beta.overrideAttrs (oldAttrs: {
    version = "8.0-beta.17+0748b0975";
    src = final.fetchurl {
      url = "https://download.zotero.org/client/beta/8.0-beta.17%2B0748b0975/Zotero-8.0-beta.17%2B0748b0975_linux-x86_64.tar.xz";
      hash = "sha256-b8TTrLnFkpuirmFcVSv8aqn00sEK/rBHJMv+Ft5VXq0=";
    };
  });
}
