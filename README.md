# A YANG Module for Entitlement Inventory

This is the working area for the IETF IVY Working Group Internet-Draft, "A YANG Module for Entitlement Inventory".

* [Editor's Copy](https://ietf-ivy-wg.github.io/network-inventory-entitlement/#go.draft-ietf-ivy-entitlement-inventory.html)
* [Datatracker Page](https://datatracker.ietf.org/doc/draft-ietf-ivy-entitlement-inventory)
* [Latest Published Draft](https://datatracker.ietf.org/doc/html/draft-ietf-ivy-entitlement-inventory)
* [Compare Editor's Copy to Latest Published Draft](https://ietf-ivy-wg.github.io/network-inventory-entitlement/#go.draft-ietf-ivy-entitlement-inventory.diff)


## Contributing

See the
[guidelines for contributions](CONTRIBUTING.md).

Contributions can be made by creating pull requests.
The GitHub interface supports creating pull requests using the Edit (✏) button.


## Command Line Usage

Before building the draft after YANG model, tree, or example changes, run the YANG checks:

```sh
$ make yang-check
```

This regenerates the YANG tree files, validates the YANG module, and validates the JSON examples under `yang/examples/valid-*.json`.

Then build the formatted text and HTML versions of the draft using `make`.

```sh
$ make
```

Command line usage requires that you have the necessary software installed. See
[the instructions](https://github.com/martinthomson/i-d-template/blob/main/doc/SETUP.md).
