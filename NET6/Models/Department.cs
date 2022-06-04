using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace NET6.Api.Models;
[Table("tblDepartment")]
public class Department
{
    [Key]
    public string? Department_Code { get; set; }
    public string? Department_Name { get; set; }
    public string? Department_Description { get; set; }
    public int FacultyID { get; set; }
}
