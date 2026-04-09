"""
This example demonstrates how to create and edit an ontology using PyCowl.
"""

from datetime import date

import cowl


def main() -> None:
    # Create a new, empty ontology.
    onto = cowl.Ontology()

    # Set the ontology IRI and default prefix, and add a comment annotation.
    onto.set_iri("http://swot.sisinflab.poliba.it/university", update_prefix=True)
    onto.add(cowl.rdfs.comment("An ontology for university-related concepts."))

    # Create entities to be used in axioms.
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
    teaches = onto.ObjectProperty("teaches")
    is_taught_by = onto.ObjectProperty("isTaughtBy")
    is_teacher_of = onto.ObjectProperty("isTeacherOf")
    is_enrolled_in = onto.ObjectProperty("isEnrolledIn")
    has_supervisor = onto.ObjectProperty("hasSupervisor")
    has_age = onto.DataProperty("hasAge")
    has_birth_date = onto.DataProperty("hasBirthDate")
    has_email = onto.DataProperty("hasEmail")
    john_doe = onto.Individual("JohnDoe")
    jane_smith = onto.Individual("JaneSmith")

    # Create and add axioms to the ontology.
    #
    # Axioms are created using PyCowl's fluent API, which allows for more concise and readable code.
    # There is also a functional API that more directly reflects the OWL 2 functional-style syntax
    # (see `examples/functional.py`).
    onto.add(
        # An adult is a person whose age is at least 18.
        adult.is_a(person.that(has_age.only(cowl.xsd.integer >= 18))),
        # A student is an adult who is enrolled in some course.
        student.is_a(adult.that(is_enrolled_in.some(course))),
        # A professor is an adult who teaches some course.
        professor.is_a(adult.that(teaches.some(course))),
        # No student is a professor.
        student.is_not_a(professor),
        # A graduate student is a student who has at least one supervisor.
        graduate_student.is_equivalent_to(student.that(has_supervisor.some(professor))),
        # An undergraduate student is not a graduate student.
        undergraduate_student.is_a(student & ~graduate_student),
        # Every student or professor is a university member.
        (student | professor).is_subclass_of(university_member),
        # Every university member is identified by an email.
        university_member.has_key(has_email),
        # Every course is taught by exactly one professor.
        course.is_subclass_of(is_taught_by.exactly(1, professor)),
        # The teaches property is the inverse of isTaughtBy.
        teaches.is_inverse_of(is_taught_by),
        # Every person has at most one age.
        has_age.is_functional(),
        # Every student has at most one supervisor.
        has_supervisor.is_functional(),
        # Every supervisor is a teacher of their supervisees.
        has_supervisor.is_subproperty_of(~is_teacher_of),
        # If a professor teaches a course and a student is enrolled in that course,
        # then the professor is a teacher of the student.
        cowl.chain(teaches, ~is_enrolled_in).is_subproperty_of(is_teacher_of),
        # The age datatype is defined as a non-negative integer less than or equal to 150.
        age.is_defined_as(cowl.xsd.non_negative_integer <= 150),
        # The email datatype is defined as a string that matches a basic email pattern.
        email.is_defined_as(cowl.xsd.string.that_has(pattern=r"^[\w\.-]+@[\w\.-]+\.\w+$")),
        # The domain of hasAge is Person and its range is Age.
        has_age.has_domain(person),
        has_age.has_range(age),
        # John Doe is a professor, Jane Smith is a graduate student, and John supervises Jane.
        john_doe.is_a(professor),
        jane_smith.is_a(graduate_student),
        has_supervisor(jane_smith, john_doe),
        # John Doe's email and birth date, and Jane Smith's age.
        has_email(john_doe, "john.doe@example.edu"),
        has_age(jane_smith, 25),
        has_birth_date(john_doe, date(1985, 5, 15)),
    )

    # Visualize the ontology.
    print(onto)


if __name__ == "__main__":
    main()
