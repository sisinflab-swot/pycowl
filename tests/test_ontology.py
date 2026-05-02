from datetime import date
from pathlib import Path
from tempfile import TemporaryDirectory

import cowl

TEST_DIR = Path(__file__).parent
RES_DIR = TEST_DIR / "res"
TEST_ONTO_PATH = RES_DIR / "test_onto.owl"


def test_round_trip() -> None:
    orig = cowl.Ontology.at_path(TEST_ONTO_PATH)

    with TemporaryDirectory() as tmp:
        tmp_path = Path(tmp) / "test_onto_out.owl"
        orig.to_path(tmp_path)
        other = cowl.Ontology.at_path(tmp_path)

    assert str(orig) == str(other)
    assert orig.iri() == other.iri()

    orig_axioms = set(orig.axioms())
    other_axioms = set(other.axioms())
    assert orig_axioms == other_axioms

    orig_annotations = set(orig.annotations())
    other_annotations = set(other.annotations())
    assert orig_annotations == other_annotations

    orig_primitives = set(orig.primitives())
    other_primitives = set(other.primitives())
    assert orig_primitives == other_primitives


def test_editing() -> None:
    onto = cowl.Ontology()
    onto.set_iri("http://swot.sisinflab.poliba.it/university", update_prefix=True)
    onto.add(cowl.rdfs.comment("An ontology for university-related concepts."))

    person = onto.Class("Person")
    adult = onto.Class("Adult")
    university_member = onto.Class("UniversityMember")
    student = onto.Class("Student")
    professor = onto.Class("Professor")
    course = onto.Class("Course")
    graduate_student = onto.Class("GraduateStudent")
    undergraduate_student = onto.Class("UndergraduateStudent")
    age = onto.Datatype("Age")
    email = onto.Datatype("Email")
    phone_number = onto.Datatype("PhoneNumber")
    teaches = onto.ObjectProperty("teaches")
    is_taught_by = onto.ObjectProperty("isTaughtBy")
    is_teacher_of = onto.ObjectProperty("isTeacherOf")
    is_enrolled_in = onto.ObjectProperty("isEnrolledIn")
    has_supervisor = onto.ObjectProperty("hasSupervisor")
    has_age = onto.DataProperty("hasAge")
    has_birth_date = onto.DataProperty("hasBirthDate")
    has_email = onto.DataProperty("hasEmail")
    has_contact = onto.DataProperty("hasContact")
    john_doe = onto.Individual("JohnDoe")
    jane_smith = onto.Individual("JaneSmith")

    axioms: tuple[cowl.Axiom, ...] = (
        adult.is_a(person.that(has_age.only(cowl.xsd.integer >= 18))),
        student.is_a(adult.that(is_enrolled_in.some(course))),
        professor.is_a(adult.that(teaches.some(course))),
        student.is_not_a(professor),
        graduate_student.is_same_as(student.that(has_supervisor.some(professor))),
        undergraduate_student.is_a(student & ~graduate_student),
        (student | professor).is_subclass_of(university_member),
        university_member.has_key(has_email),
        course.is_subclass_of(is_taught_by.exactly(1, professor)),
        teaches.is_inverse_of(is_taught_by),
        has_age.is_functional(),
        has_supervisor.is_functional(),
        has_supervisor.is_subproperty_of(~is_teacher_of),
        cowl.chain(teaches, ~is_enrolled_in).is_subproperty_of(is_teacher_of),
        age.is_defined_as(cowl.xsd.non_negative_integer <= 150),
        email.is_defined_as(cowl.xsd.string.that_has(pattern=r"^[\w\.-]+@[\w\.-]+\.\w+$")),
        has_age.has_domain(person),
        has_age.has_range(age),
        has_contact.has_domain(university_member),
        has_contact.has_range(cowl.union_of(email, phone_number)),
        john_doe.is_a(professor),
        jane_smith.is_a(graduate_student),
        has_supervisor(jane_smith, john_doe),
        has_email(john_doe, "john.doe@example.edu"),
        has_age(jane_smith, 25),
        has_birth_date(john_doe, date(1985, 5, 15)),
    )

    onto.add(*axioms)

    assert len(onto) == len(axioms)
    assert onto.axiom_count() == len(axioms)
    assert onto.axiom_count((cowl.SubClassOf, cowl.ClassAssertion)) == sum(
        1 for ax in axioms if isinstance(ax, (cowl.SubClassOf, cowl.ClassAssertion))
    )
    assert onto.axiom_count(student) == sum(1 for a in axioms if a.has_primitive(student))
    assert onto.primitive_count(cowl.Individual) == len(
        {p for a in axioms for p in a.primitives(cowl.Individual)},
    )

    for axiom in axioms:
        assert axiom in onto
        assert axiom in onto.axioms()

    onto.remove(*axioms)

    for axiom in axioms:
        assert axiom not in onto
        assert axiom not in onto.axioms()
