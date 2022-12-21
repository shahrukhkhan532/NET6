namespace NET6.Tests.MockData;

public class DepartmentMockData
{
    
    public static List<Department> GetDepartments()
    {
        
        return new List<Department>()
        {
            new Department(){ Department_Code = "1", Department_Description = "Description 1", Department_Name = "CS", FacultyID = 1 },
            new Department(){ Department_Code = "2", Department_Description = "Description 2", Department_Name = "Telecom", FacultyID = 1 },
            new Department(){ Department_Code = "3", Department_Description = "Description 3", Department_Name = "science", FacultyID = 1 },
            new Department(){ Department_Code = "4", Department_Description = "Description 4", Department_Name = "IT", FacultyID = 1 },
            new Department(){ Department_Code = "5", Department_Description = "Description 5", Department_Name = "Agriculture", FacultyID = 1 },
        };
    }
    public static List<Department> GetDepartmentsEmptyCollection()
    {
        return new List<Department>();
    }
    public static Department AddDepartment()
    {
        return new Department()
        {
            Department_Code = "12",
            Department_Name = "BS CS",
            Department_Description = "Lorem ipsum",
            FacultyID = 12
        };
    }
}
