import pytest

from hbayesdm.models import bart_prospect_phi


def test_bart_prospect_phi():
    _ = bart_prospect_phi(
        data="example", niter=10, nwarmup=5, nchain=1, ncore=1)


if __name__ == '__main__':
    pytest.main()
