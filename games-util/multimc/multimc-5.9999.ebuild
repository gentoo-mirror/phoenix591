# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit eutils cmake-utils git-r3

DESCRIPTION="An advanced open-source launcher for Minecraft written in Qt5."
HOMEPAGE="https://multimc.org/"
EGIT_REPO_URI="https://github.com/MultiMC/MultiMC5.git"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS=""
IUSE="+zlib"
COMMON_DEPEND="
		 sys-libs/zlib:0=
		>=dev-qt/qtcore-5.6.0:5
		>=dev-qt/qtwidgets-5.6.0:5
		>=dev-qt/qtconcurrent-5.6.0:5
		>=dev-qt/qtnetwork-5.6.0:5
		>=dev-qt/qttest-5.6.0:5
		>=dev-qt/qtgui-5.6.0:5[png]
		>=dev-qt/qtxml-5.6.0:5
		dev-libs/icu:0="
DEPEND="${COMMON_DEPEND}
		virtual/jdk"
RDEPEND="${COMMON_DEPEND}
		virtual/jre
		virtual/opengl
		x11-apps/xrandr:*"

PATCHES=(
#		"${FILESDIR}/fortify-fix.patch"
)

src_prepare() {
	git submodule update --init
	cmake-utils_src_prepare
}

src_configure() {
	local mycmakeargs=(
			-DCMAKE_BUILD_TYPE=Release
			-DCMAKE_INSTALL_PREFIX="/usr"
			-DMultiMC_LAYOUT=lin-system
			-DNBT_USE_ZLIB="$(usex zlib)"
			-DMultiMC_NOTIFICATION_URL:STRING="https://files.multimc.org/notifications.json"

	)
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
	mkdir -p "${D}/usr/share/pixmaps" "${D}/usr/share/applications"
	cp "${S}/application/resources/multimc/scalable/multimc.svg" "${D}/usr/share/pixmaps/multimc5.svg"0
	cp "${FILESDIR}/multimc5.desktop" "${D}/usr/share/applications/multimc5.desktop"
}
