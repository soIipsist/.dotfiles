from scripts.tests.test_base import TestBase, run_test_methods


class TestOrganize(TestBase):
    def setUp(self) -> None:
        super().setUp()

    def test_organize_photos(self):
        pass

    def test_organize_videos(self):
        pass


if __name__ == "__main__":
    test_methods = [
        # TestOrganize.test_organize_photos,
        # TestOrganize.test_organize_videos,
    ]
    run_test_methods(test_methods)
