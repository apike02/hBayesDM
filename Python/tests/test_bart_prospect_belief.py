import pytest

from hbayesdm.models import bart_prospect_belief


def test_bart_prospect_belief():
    _ = bart_prospect_belief(
        data="example", niter=10, nwarmup=5, nchain=1, ncore=1)


if __name__ == '__main__':
    pytest.main()
