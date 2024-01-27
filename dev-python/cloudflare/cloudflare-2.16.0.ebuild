# Copyright 2021-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10..12} )
DISTUTILS_USE_PEP517="setuptools"
inherit distutils-r1

DESCRIPTION="Python wrapper for the Cloudflare v4 API"
HOMEPAGE="https://pypi.org/project/cloudflare/"
#SRC_URI="https://files.pythonhosted.org/packages/9b/8c/973e3726c2aa73821bb4272717c6f9f6fc74e69d41ba871bdf97fc671782/${P}.tar.gz"
#SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"
SRC_URI="https://github.com/cloudflare/python-cloudflare/archive/refs/tags/${PV}.tar.gz -> ${P}.gh.tar.gz"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
DEPEND="dev-python/jsonlines[${PYTHON_USEDEP}]"
RDEPEND="( ${DEPEND}
	dev-python/requests[${PYTHON_USEDEP}]
	dev-python/pyyaml[${PYTHON_USEDEP}] )"
S="${WORKDIR}/python-${P}"
PROPERTIES="test_network" #actually sends a test request
RESTRICT="test mirror" #mirror restricted only becausw overlay
distutils_enable_tests pytest
python_prepare_all() {
	# don't install tests or examples
	sed -i -e "s/'cli4', 'examples'/'cli4'/" \
		 setup.py || die

	distutils-r1_python_prepare_all
}
python_test() {
	pushd  CloudFlare/tests
	if [ -z "${CLOUDFLARE_API_TOKEN}" ]; then
		ewarn "Skipping some tests which require an actual cloudflare api token"
		ewarn "To run them, provide the token in the environment variable CLOUDFLARE_API_TOKEN"
		ewarn "The permissions needed are zone dns edit and user details read"
		local EPYTEST_IGNORE=('test_dns_records.py' 'test_radar_returning_csv.py'
			'test_dns_import_export.py' 'test_graphql.py' 'test_workers.py' )
		# these test(s) need an api key/token setup
		# Permissions needed are zone dns edit and user details read, account worker scripts edit,
			#  zone analytics read
	fi
	# Not sure what permissions/tokens/whatever this test needs, maybe both a token and old api login
	# tried several of the ssl related options for the cert test but no luck either
	# Tried several of the prefex related options to try to get loa docs working but nope
	local EPYTEST_IGNORE+=('test_issue114.py' 'test_certificates.py' 'test_loa_documents.py' )
	epytest
}